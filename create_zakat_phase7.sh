#!/bin/bash
set -e

MODULE_PATH="app/Modules/Zakat"

echo "🚀 Creating Zakat Engine Module (Phase 7)..."

# =========================
# Directories
mkdir -p $MODULE_PATH/{Models,Domain/Events,Application/Commands,Application/Handlers,Application/Listeners,Database/Migrations,Providers}

# =========================
# Zakat Model
cat <<'PHP' > $MODULE_PATH/Models/Zakat.php
<?php
namespace App\Modules\Zakat\Models;
use Illuminate\Database\Eloquent\Model;
class Zakat extends Model {
    protected $fillable=['reference_type','reference_id','amount','status'];
}
PHP

# =========================
# Migration
TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)
cat <<PHP > $MODULE_PATH/Database/Migrations/${TIMESTAMP}_create_zakat_table.php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('zakat',function(Blueprint \$table){
            \$table->id();
            \$table->string('reference_type');
            \$table->unsignedBigInteger('reference_id');
            \$table->decimal('amount',12,2);
            \$table->enum('status',['pending','calculated','posted'])->default('pending');
            \$table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('zakat'); }
};
PHP

# =========================
# Command
cat <<'PHP' > $MODULE_PATH/Application/Commands/CalculateZakatCommand.php
<?php
namespace App\Modules\Zakat\Application\Commands;
class CalculateZakatCommand {
    public function __construct(public readonly string $referenceType,public readonly int $referenceId,public readonly float $amount) {}
}
PHP

# =========================
# Event
cat <<'PHP' > $MODULE_PATH/Domain/Events/ZakatCalculated.php
<?php
namespace App\Modules\Zakat\Domain\Events;
class ZakatCalculated {
    public function __construct(public readonly string $referenceType,public readonly int $referenceId,public readonly float $amount) {}
}
PHP

# =========================
# Handler
cat <<'PHP' > $MODULE_PATH/Application/Handlers/CalculateZakatHandler.php
<?php
namespace App\Modules\Zakat\Application\Handlers;
use App\Modules\Zakat\Application\Commands\CalculateZakatCommand;
use App\Modules\Zakat\Models\Zakat;
use App\Modules\Zakat\Domain\Events\ZakatCalculated;
use Illuminate\Support\Facades\Event;

class CalculateZakatHandler{
    public function handle(CalculateZakatCommand $command): Zakat{
        $zakatAmount=round($command->amount*0.025,2);
        $zakat=Zakat::create([
            'reference_type'=>$command->referenceType,
            'reference_id'=>$command->referenceId,
            'amount'=>$zakatAmount,
            'status'=>'calculated',
        ]);
        Event::dispatch(new ZakatCalculated($command->referenceType,$command->referenceId,$zakatAmount));
        return $zakat;
    }
}
PHP

# =========================
# Listeners
# DonationConfirmed → Calculate Zakat
cat <<'PHP' > $MODULE_PATH/Application/Listeners/DonationConfirmedListener.php
<?php
namespace App\Modules\Zakat\Application\Listeners;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use App\Modules\Zakat\Application\Commands\CalculateZakatCommand;
use App\Modules\Zakat\Application\Handlers\CalculateZakatHandler;

class DonationConfirmedListener{
    protected CalculateZakatHandler $handler;
    public function __construct(CalculateZakatHandler $handler){ $this->handler=$handler; }
    public function handle(DonationConfirmed $event): void{
        $this->handler->handle(new CalculateZakatCommand('donation',$event->donationId,$event->amount));
    }
}
PHP

# AllocationCreated → Calculate Zakat
cat <<'PHP' > $MODULE_PATH/Application/Listeners/AllocationCreatedListener.php
<?php
namespace App\Modules\Zakat\Application\Listeners;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Zakat\Application\Commands\CalculateZakatCommand;
use App\Modules\Zakat\Application\Handlers\CalculateZakatHandler;

class AllocationCreatedListener{
    protected CalculateZakatHandler $handler;
    public function __construct(CalculateZakatHandler $handler){ $this->handler=$handler; }
    public function handle(AllocationCreated $event): void{
        $this->handler->handle(new CalculateZakatCommand('allocation',$event->allocationId,$event->amount));
    }
}
PHP

# =========================
# Service Provider
cat <<'PHP' > $MODULE_PATH/Providers/ZakatServiceProvider.php
<?php
namespace App\Modules\Zakat\Providers;
use Illuminate\Support\ServiceProvider;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Zakat\Application\Listeners\DonationConfirmedListener;
use App\Modules\Zakat\Application\Listeners\AllocationCreatedListener;
use Illuminate\Support\Facades\Event;

class ZakatServiceProvider extends ServiceProvider{
    public function boot(): void{
        $this->loadMigrationsFrom(__DIR__.'/../Database/Migrations');
        Event::listen(DonationConfirmed::class,[DonationConfirmedListener::class,'handle']);
        Event::listen(AllocationCreated::class,[AllocationCreatedListener::class,'handle']);
    }
}
PHP

# =========================
# Register Provider
PROVIDERS_FILE="config/app.php"
if ! grep -q "ZakatServiceProvider" "$PROVIDERS_FILE"; then
    sed -i "/providers => \[/a\\
        App\\\\Modules\\\\Zakat\\\\Providers\\\\ZakatServiceProvider::class," $PROVIDERS_FILE
fi

echo "✅ Zakat Engine Phase 7 ready!"
echo "➡️ Run: php artisan migrate"
echo "➡️ Zakat now calculated automatically on DonationConfirmed & AllocationCreated"
