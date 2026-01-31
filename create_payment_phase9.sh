#!/bin/bash
set -e

MODULE_PATH="app/Modules/Payments"

echo "🚀 Creating Payments Module (Phase 9)..."

# =========================
# Directories
mkdir -p $MODULE_PATH/{Models,Domain/Events,Application/Commands,Application/Handlers,Application/Listeners,Database/Migrations,Controllers,Routes,Providers}

# =========================
# Payment Model
cat <<'PHP' > $MODULE_PATH/Models/Payment.php
<?php
namespace App\Modules\Payments\Models;
use Illuminate\Database\Eloquent\Model;
class Payment extends Model {
    protected $fillable=['donation_id','amount','currency','payment_method','status'];
}
PHP

# =========================
# Migration
TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)
cat <<PHP > $MODULE_PATH/Database/Migrations/${TIMESTAMP}_create_payments_table.php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('payments',function(Blueprint \$table){
            \$table->id();
            \$table->foreignId('donation_id')->constrained('donations')->cascadeOnDelete();
            \$table->decimal('amount',12,2);
            \$table->string('currency',3);
            \$table->string('payment_method');
            \$table->enum('status',['pending','confirmed','failed'])->default('pending');
            \$table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('payments'); }
};
PHP

# =========================
# Command
cat <<'PHP' > $MODULE_PATH/Application/Commands/ProcessPaymentCommand.php
<?php
namespace App\Modules\Payments\Application\Commands;
class ProcessPaymentCommand {
    public function __construct(public readonly int $donationId, public readonly float $amount, public readonly string $currency, public readonly string $paymentMethod) {}
}
PHP

# =========================
# Event
cat <<'PHP' > $MODULE_PATH/Domain/Events/PaymentConfirmed.php
<?php
namespace App\Modules\Payments\Domain\Events;
class PaymentConfirmed {
    public function __construct(public readonly int $paymentId, public readonly int $donationId, public readonly float $amount, public readonly string $currency, public readonly string $paymentMethod) {}
}
PHP

# =========================
# Handler
cat <<'PHP' > $MODULE_PATH/Application/Handlers/ProcessPaymentHandler.php
<?php
namespace App\Modules\Payments\Application\Handlers;
use App\Modules\Payments\Application\Commands\ProcessPaymentCommand;
use App\Modules\Payments\Models\Payment;
use App\Modules\Payments\Domain\Events\PaymentConfirmed;
use Illuminate\Support\Facades\Event;

class ProcessPaymentHandler{
    public function handle(ProcessPaymentCommand $command): Payment{
        // Here you can integrate external gateway API
        $payment=Payment::create([
            'donation_id'=>$command->donationId,
            'amount'=>$command->amount,
            'currency'=>$command->currency,
            'payment_method'=>$command->paymentMethod,
            'status'=>'confirmed',
        ]);

        Event::dispatch(new PaymentConfirmed($payment->id,$payment->donation_id,$payment->amount,$payment->currency,$payment->payment_method));
        return $payment;
    }
}
PHP

# =========================
# Listener: DonationConfirmed → ProcessPayment
cat <<'PHP' > $MODULE_PATH/Application/Listeners/DonationConfirmedListener.php
<?php
namespace App\Modules\Payments\Application\Listeners;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use App\Modules\Payments\Application\Commands\ProcessPaymentCommand;
use App\Modules\Payments\Application\Handlers\ProcessPaymentHandler;

class DonationConfirmedListener{
    protected ProcessPaymentHandler $handler;
    public function __construct(ProcessPaymentHandler $handler){ $this->handler=$handler; }
    public function handle(DonationConfirmed $event): void{
        $this->handler->handle(new ProcessPaymentCommand($event->donationId,$event->amount,$event->currency,'card'));
    }
}
PHP

# =========================
# Controller
cat <<'PHP' > $MODULE_PATH/Controllers/PaymentController.php
<?php
namespace App\Modules\Payments\Controllers;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Modules\Payments\Application\Commands\ProcessPaymentCommand;
use App\Modules\Payments\Application\Handlers\ProcessPaymentHandler;

class PaymentController extends Controller {
    public function pay(Request $request, ProcessPaymentHandler $handler){
        $data=$request->validate([
            'donation_id'=>'required|exists:donations,id',
            'amount'=>'required|numeric|min:1',
            'currency'=>'required|string|size:3',
            'payment_method'=>'required|string',
        ]);
        $payment=$handler->handle(new ProcessPaymentCommand($data['donation_id'],$data['amount'],$data['currency'],$data['payment_method']));
        return response()->json(['success'=>true,'payment_id'=>$payment->id,'status'=>$payment->status]);
    }
}
PHP

# =========================
# Routes
cat <<'PHP' > $MODULE_PATH/Routes/api.php
<?php
use Illuminate\Support\Facades\Route;
use App\Modules\Payments\Controllers\PaymentController;
Route::post('/payment',[PaymentController::class,'pay']);
PHP

# =========================
# Service Provider
cat <<'PHP' > $MODULE_PATH/Providers/PaymentsServiceProvider.php
<?php
namespace App\Modules\Payments\Providers;
use Illuminate\Support\ServiceProvider;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use App\Modules\Payments\Application\Listeners\DonationConfirmedListener;
use Illuminate\Support\Facades\Event;

class PaymentsServiceProvider extends ServiceProvider{
    public function boot(): void{
        $this->loadRoutesFrom(__DIR__.'/../Routes/api.php');
        $this->loadMigrationsFrom(__DIR__.'/../Database/Migrations');
        Event::listen(DonationConfirmed::class,[DonationConfirmedListener::class,'handle']);
    }
}
PHP

# =========================
# Register Provider
PROVIDERS_FILE="config/app.php"
if ! grep -q "PaymentsServiceProvider" "$PROVIDERS_FILE"; then
    sed -i "/providers => \[/a\\
        App\\\\Modules\\\\Payments\\\\Providers\\\\PaymentsServiceProvider::class," $PROVIDERS_FILE
fi

echo "✅ Payments Module Phase 9 ready!"
echo "➡️ Run: php artisan migrate"
echo "➡️ DonationConfirmed events now trigger Payment Processing automatically"
