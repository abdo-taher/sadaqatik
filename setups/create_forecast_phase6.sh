#!/bin/bash
set -e

MODULE_PATH="app/Modules/Forecast"

echo "🚀 Creating Forecast & Budget Control Module (Phase 6)..."

# =========================
# Directories
mkdir -p $MODULE_PATH/{Models,Domain/Events,Application/Commands,Application/Handlers,Application/Listeners,Controllers,Routes,Database/Migrations,Providers}

# =========================
# Forecast Model
cat <<'PHP' > $MODULE_PATH/Models/Forecast.php
<?php
namespace App\Modules\Forecast\Models;
use Illuminate\Database\Eloquent\Model;
class Forecast extends Model {
    protected $fillable=['project_id','allocated','spent','budget'];
}
PHP

# =========================
# Migration
TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)
cat <<PHP > $MODULE_PATH/Database/Migrations/${TIMESTAMP}_create_forecast_table.php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('forecast',function(Blueprint \$table){
            \$table->id();
            \$table->foreignId('project_id')->constrained('projects')->cascadeOnDelete();
            \$table->decimal('budget',12,2)->default(0);
            \$table->decimal('allocated',12,2)->default(0);
            \$table->decimal('spent',12,2)->default(0);
            \$table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('forecast'); }
};
PHP

# =========================
# Command
cat <<'PHP' > $MODULE_PATH/Application/Commands/CheckBudgetCommand.php
<?php
namespace App\Modules\Forecast\Application\Commands;
class CheckBudgetCommand {
    public function __construct(public readonly int $projectId, public readonly float $amount, public readonly string $type) {}
}
PHP

# =========================
# Events
cat <<'PHP' > $MODULE_PATH/Domain/Events/ForecastChecked.php
<?php
namespace App\Modules\Forecast\Domain\Events;
class ForecastChecked {
    public function __construct(public readonly int $projectId, public readonly float $allocated, public readonly float $spent, public readonly float $budget) {}
}
PHP

cat <<'PHP' > $MODULE_PATH/Domain/Events/BudgetExceeded.php
<?php
namespace App\Modules\Forecast\Domain\Events;
class BudgetExceeded {
    public function __construct(public readonly int $projectId, public readonly float $amount, public readonly string $type) {}
}
PHP

# =========================
# Handler
cat <<'PHP' > $MODULE_PATH/Application/Handlers/CheckBudgetHandler.php
<?php
namespace App\Modules\Forecast\Application\Handlers;
use App\Modules\Forecast\Application\Commands\CheckBudgetCommand;
use App\Modules\Forecast\Models\Forecast;
use App\Modules\Forecast\Domain\Events\ForecastChecked;
use App\Modules\Forecast\Domain\Events\BudgetExceeded;
use Illuminate\Support\Facades\Event;

class CheckBudgetHandler{
    public function handle(CheckBudgetCommand $command): void{
        $forecast = Forecast::firstOrCreate(['project_id'=>$command->projectId],['budget'=>0,'allocated'=>0,'spent'=>0]);

        if($command->type==='allocation'){
            $newAllocated=$forecast->allocated + $command->amount;
            if($newAllocated > $forecast->budget){
                Event::dispatch(new BudgetExceeded($command->projectId,$command->amount,'allocation'));
                return;
            }
            $forecast->allocated = $newAllocated;
        }

        if($command->type==='spending'){
            $newSpent=$forecast->spent + $command->amount;
            if($newSpent > $forecast->budget){
                Event::dispatch(new BudgetExceeded($command->projectId,$command->amount,'spending'));
                return;
            }
            $forecast->spent = $newSpent;
        }

        $forecast->save();
        Event::dispatch(new ForecastChecked($forecast->project_id,$forecast->allocated,$forecast->spent,$forecast->budget));
    }
}
PHP

# =========================
# Listener: AllocationCreated → CheckBudget
cat <<'PHP' > $MODULE_PATH/Application/Listeners/AllocationCreatedListener.php
<?php
namespace App\Modules\Forecast\Application\Listeners;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Forecast\Application\Commands\CheckBudgetCommand;
use App\Modules\Forecast\Application\Handlers\CheckBudgetHandler;

class AllocationCreatedListener{
    protected CheckBudgetHandler $handler;
    public function __construct(CheckBudgetHandler $handler){ $this->handler=$handler; }
    public function handle(AllocationCreated $event): void{
        $this->handler->handle(new CheckBudgetCommand($event->projectId,$event->amount,'allocation'));
    }
}
PHP

# =========================
# Listener: SpendingCreated → CheckBudget
cat <<'PHP' > $MODULE_PATH/Application/Listeners/SpendingCreatedListener.php
<?php
namespace App\Modules\Forecast\Application\Listeners;
use App\Modules\Spending\Domain\Events\SpendingCreated;
use App\Modules\Forecast\Application\Commands\CheckBudgetCommand;
use App\Modules\Forecast\Application\Handlers\CheckBudgetHandler;

class SpendingCreatedListener{
    protected CheckBudgetHandler $handler;
    public function __construct(CheckBudgetHandler $handler){ $this->handler=$handler; }
    public function handle(SpendingCreated $event): void{
        $this->handler->handle(new CheckBudgetCommand($event->allocationId,$event->amount,'spending'));
    }
}
PHP

# =========================
# Service Provider
cat <<'PHP' > $MODULE_PATH/Providers/ForecastServiceProvider.php
<?php
namespace App\Modules\Forecast\Providers;
use Illuminate\Support\ServiceProvider;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Spending\Domain\Events\SpendingCreated;
use App\Modules\Forecast\Application\Listeners\AllocationCreatedListener;
use App\Modules\Forecast\Application\Listeners\SpendingCreatedListener;
use Illuminate\Support\Facades\Event;

class ForecastServiceProvider extends ServiceProvider{
    public function boot(): void{
        $this->loadMigrationsFrom(__DIR__.'/../Database/Migrations');
        Event::listen(AllocationCreated::class,[AllocationCreatedListener::class,'handle']);
        Event::listen(SpendingCreated::class,[SpendingCreatedListener::class,'handle']);
    }
}
PHP

# =========================
# Register Provider
PROVIDERS_FILE="config/app.php"
if ! grep -q "ForecastServiceProvider" "$PROVIDERS_FILE"; then
    sed -i "/providers => \[/a\\
        App\\\\Modules\\\\Forecast\\\\Providers\\\\ForecastServiceProvider::class," $PROVIDERS_FILE
fi

echo "✅ Forecast & Budget Control Phase 6 ready!"
echo "➡️ Run: php artisan migrate"
echo "➡️ Allocation / Spending events now check budgets automatically"
