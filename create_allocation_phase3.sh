#!/bin/bash

set -e

MODULE_PATH="app/Modules/Allocation"

echo "🚀 Creating Allocation Module (Phase 4)..."

# =========================
# Directories
# =========================
mkdir -p $MODULE_PATH/{Models,Domain/Events,Application/Commands,Application/Handlers,Application/Listeners,Database/Migrations,Providers,Controllers,Routes}

# =========================
# Model
# =========================
cat <<'PHP' > $MODULE_PATH/Models/Allocation.php
<?php

namespace App\Modules\Allocation\Models;

use Illuminate\Database\Eloquent\Model;

class Allocation extends Model
{
    protected $fillable = [
        'donation_id',
        'project_id',
        'amount',
        'allocated_by',
        'status',
    ];
}
PHP

# =========================
# Migration
TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)
cat <<PHP > $MODULE_PATH/Database/Migrations/${TIMESTAMP}_create_allocations_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('allocations', function (Blueprint \$table) {
            \$table->id();

            \$table->foreignId('donation_id')->constrained('donations')->cascadeOnDelete();
            \$table->foreignId('project_id')->constrained('projects')->cascadeOnDelete();

            \$table->decimal('amount', 12, 2);
            \$table->string('allocated_by');

            \$table->enum('status', ['pending', 'completed'])->default('pending');

            \$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('allocations');
    }
};
PHP

# =========================
# Command
cat <<'PHP' > $MODULE_PATH/Application/Commands/CreateAllocationCommand.php
<?php

namespace App\Modules\Allocation\Application\Commands;

class CreateAllocationCommand
{
    public function __construct(
        public readonly int $donationId,
        public readonly int $projectId,
        public readonly float $amount,
        public readonly string $allocatedBy
    ) {}
}
PHP

# =========================
# Event
cat <<'PHP' > $MODULE_PATH/Domain/Events/AllocationCreated.php
<?php

namespace App\Modules\Allocation\Domain\Events;

class AllocationCreated
{
    public function __construct(
        public readonly int $allocationId,
        public readonly int $donationId,
        public readonly int $projectId,
        public readonly float $amount
    ) {}
}
PHP

# =========================
# Handler
cat <<'PHP' > $MODULE_PATH/Application/Handlers/CreateAllocationHandler.php
<?php

namespace App\Modules\Allocation\Application\Handlers;

use App\Modules\Allocation\Application\Commands\CreateAllocationCommand;
use App\Modules\Allocation\Models\Allocation;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use Illuminate\Support\Facades\Event;

class CreateAllocationHandler
{
    public function handle(CreateAllocationCommand $command): Allocation
    {
        $allocation = Allocation::create([
            'donation_id' => $command->donationId,
            'project_id' => $command->projectId,
            'amount' => $command->amount,
            'allocated_by' => $command->allocatedBy,
            'status' => 'completed',
        ]);

        Event::dispatch(
            new AllocationCreated(
                $allocation->id,
                $allocation->donation_id,
                $allocation->project_id,
                $allocation->amount
            )
        );

        return $allocation;
    }
}
PHP

# =========================
# Listener – LedgerEntry
cat <<'PHP' > $MODULE_PATH/Application/Listeners/AllocationCreatedListener.php
<?php

namespace App\Modules\Allocation\Application\Listeners;

use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Core\Ledger\Models\LedgerEntry;

class AllocationCreatedListener
{
    public function handle(AllocationCreated $event): void
    {
        // Double Entry: Project Fund / Donations Revenue
        LedgerEntry::create([
            'reference_type' => 'Allocation',
            'reference_id' => $event->allocationId,
            'account_debit' => 'Project Fund',
            'account_credit' => 'Donations Revenue',
            'amount' => $event->amount,
            'currency' => 'EGP',
            'status' => 'posted',
        ]);
    }
}
PHP

# =========================
# Controller
cat <<'PHP' > $MODULE_PATH/Controllers/AllocationController.php
<?php

namespace App\Modules\Allocation\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Modules\Allocation\Application\Handlers\CreateAllocationHandler;
use App\Modules\Allocation\Application\Commands\CreateAllocationCommand;

class AllocationController extends Controller
{
    public function store(Request $request, CreateAllocationHandler $handler)
    {
        $data = $request->validate([
            'donation_id' => 'required|exists:donations,id',
            'project_id' => 'required|exists:projects,id',
            'amount' => 'required|numeric|min:1',
            'allocated_by' => 'required|string',
        ]);

        $allocation = $handler->handle(
            new CreateAllocationCommand(
                $data['donation_id'],
                $data['project_id'],
                $data['amount'],
                $data['allocated_by']
            )
        );

        return response()->json([
            'success' => true,
            'allocation_id' => $allocation->id,
            'status' => $allocation->status,
        ]);
    }
}
PHP

# =========================
# Routes
cat <<'PHP' > $MODULE_PATH/Routes/api.php
<?php

use Illuminate\Support\Facades\Route;
use App\Modules\Allocation\Controllers\AllocationController;

Route::post('/allocations', [AllocationController::class, 'store']);
PHP

# =========================
# Service Provider
cat <<'PHP' > $MODULE_PATH/Providers/AllocationServiceProvider.php
<?php

namespace App\Modules\Allocation\Providers;

use Illuminate\Support\ServiceProvider;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Allocation\Application\Listeners\AllocationCreatedListener;
use Illuminate\Support\Facades\Event;

class AllocationServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadRoutesFrom(__DIR__ . '/../Routes/api.php');
        $this->loadMigrationsFrom(__DIR__ . '/../Database/Migrations');

        Event::listen(AllocationCreated::class, [AllocationCreatedListener::class, 'handle']);
    }
}
PHP

# =========================
# Register Provider
PROVIDERS_FILE="config/app.php"

if ! grep -q "AllocationServiceProvider" "$PROVIDERS_FILE"; then
    sed -i "/providers => \[/a\\
        App\\\\Modules\\\\Allocation\\\\Providers\\\\AllocationServiceProvider::class," $PROVIDERS_FILE
fi

echo "✅ Allocation Module Phase 4 ready!"
echo "➡️ Run: php artisan migrate"
echo "➡️ POST /api/allocations to create allocation (triggers LedgerEntry)"
