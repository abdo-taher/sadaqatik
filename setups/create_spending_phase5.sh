#!/bin/bash
set -e

MODULE_PATH="app/Modules/Spending"

echo "🚀 Creating Spending Module (Phase 5)..."

# =========================
# Directories
mkdir -p $MODULE_PATH/{Models,Domain/Events,Application/Commands,Application/Handlers,Application/Listeners,Database/Migrations,Controllers,Routes,Providers}

# =========================
# Spending Model
cat <<'PHP' > $MODULE_PATH/Models/Spending.php
<?php
namespace App\Modules\Spending\Models;
use Illuminate\Database\Eloquent\Model;
class Spending extends Model {
    protected $fillable=['allocation_id','amount','spent_by','description','status'];
}
PHP

# =========================
# Migration
TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)
cat <<PHP > $MODULE_PATH/Database/Migrations/${TIMESTAMP}_create_spending_table.php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('spending',function(Blueprint \$table){
            \$table->id();
            \$table->foreignId('allocation_id')->constrained('allocations')->cascadeOnDelete();
            \$table->decimal('amount',12,2);
            \$table->string('spent_by');
            \$table->string('description')->nullable();
            \$table->enum('status',['pending','completed'])->default('pending');
            \$table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('spending'); }
};
PHP

# =========================
# Command
cat <<'PHP' > $MODULE_PATH/Application/Commands/CreateSpendingCommand.php
<?php
namespace App\Modules\Spending\Application\Commands;
class CreateSpendingCommand {
    public function __construct(public readonly int $allocationId,public readonly float $amount,public readonly string $spentBy,public readonly ?string $description=null) {}
}
PHP

# =========================
# Event
cat <<'PHP' > $MODULE_PATH/Domain/Events/SpendingCreated.php
<?php
namespace App\Modules\Spending\Domain\Events;
class SpendingCreated {
    public function __construct(public readonly int $spendingId,public readonly int $allocationId,public readonly float $amount,public readonly string $spentBy,public readonly ?string $description=null) {}
}
PHP

# =========================
# Handler
cat <<'PHP' > $MODULE_PATH/Application/Handlers/CreateSpendingHandler.php
<?php
namespace App\Modules\Spending\Application\Handlers;
use App\Modules\Spending\Application\Commands\CreateSpendingCommand;
use App\Modules\Spending\Models\Spending;
use App\Modules\Spending\Domain\Events\SpendingCreated;
use Illuminate\Support\Facades\Event;
class CreateSpendingHandler{
    public function handle(CreateSpendingCommand $command): Spending{
        $spending=Spending::create([
            'allocation_id'=>$command->allocationId,
            'amount'=>$command->amount,
            'spent_by'=>$command->spentBy,
            'description'=>$command->description,
            'status'=>'completed',
        ]);
        Event::dispatch(new SpendingCreated($spending->id,$spending->allocation_id,$spending->amount,$spending->spent_by,$spending->description));
        return $spending;
    }
}
PHP

# =========================
# Listener: SpendingCreated → LedgerEntry
cat <<'PHP' > $MODULE_PATH/Application/Listeners/SpendingCreatedListener.php
<?php
namespace App\Modules\Spending\Application\Listeners;
use App\Modules\Spending\Domain\Events\SpendingCreated;
use App\Modules\Core\Ledger\Models\LedgerEntry;
class SpendingCreatedListener{
    public function handle(SpendingCreated $event): void{
        // Double Entry: Expense / Project Fund
        LedgerEntry::create([
            'reference_type'=>'Spending',
            'reference_id'=>$event->spendingId,
            'account_debit'=>'Project Expense',
            'account_credit'=>'Project Fund',
            'amount'=>$event->amount,
            'currency'=>'EGP',
            'status'=>'posted',
        ]);
    }
}
PHP

# =========================
# Controller
cat <<'PHP' > $MODULE_PATH/Controllers/SpendingController.php
<?php
namespace App\Modules\Spending\Controllers;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Modules\Spending\Application\Commands\CreateSpendingCommand;
use App\Modules\Spending\Application\Handlers\CreateSpendingHandler;

class SpendingController extends Controller {
    public function store(Request $request, CreateSpendingHandler $handler){
        $data=$request->validate([
            'allocation_id'=>'required|exists:allocations,id',
            'amount'=>'required|numeric|min:1',
            'spent_by'=>'required|string',
            'description'=>'nullable|string',
        ]);
        $spending=$handler->handle(new CreateSpendingCommand($data['allocation_id'],$data['amount'],$data['spent_by'],$data['description']??null));
        return response()->json(['success'=>true,'spending_id'=>$spending->id,'status'=>$spending->status]);
    }
}
PHP

# =========================
# Routes
cat <<'PHP' > $MODULE_PATH/Routes/api.php
<?php
use Illuminate\Support\Facades\Route;
use App\Modules\Spending\Controllers\SpendingController;
Route::post('/spending',[SpendingController::class,'store']);
PHP

# =========================
# Service Provider
cat <<'PHP' > $MODULE_PATH/Providers/SpendingServiceProvider.php
<?php
namespace App\Modules\Spending\Providers;
use Illuminate\Support\ServiceProvider;
use App\Modules\Spending\Domain\Events\SpendingCreated;
use App\Modules\Spending\Application\Listeners\SpendingCreatedListener;
use Illuminate\Support\Facades\Event;

class SpendingServiceProvider extends ServiceProvider {
    public function boot(): void{
        $this->loadRoutesFrom(__DIR__.'/../Routes/api.php');
        $this->loadMigrationsFrom(__DIR__.'/../Database/Migrations');
        Event::listen(SpendingCreated::class,[SpendingCreatedListener::class,'handle']);
    }
}
PHP

# =========================
# Register Provider
PROVIDERS_FILE="config/app.php"
if ! grep -q "SpendingServiceProvider" "$PROVIDERS_FILE"; then
    sed -i "/providers => \[/a\\
        App\\\\Modules\\\\Spending\\\\Providers\\\\SpendingServiceProvider::class," $PROVIDERS_FILE
fi

echo "✅ Spending Module Phase 5 ready!"
echo "➡️ Run: php artisan migrate"
echo "➡️ POST /api/spending to create Spending (Allocation + Ledger auto)"
