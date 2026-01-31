#!/bin/bash

set -e

MODULE_PATH="app/Modules/Donations"

echo "🚀 Creating Donations Module (Phase 3)..."

# =========================
# Directories
# =========================
mkdir -p $MODULE_PATH/{Models,Domain/Events,Application/Commands,Application/Handlers,Controllers,Routes,Database/Migrations,Providers}

# =========================
# Model
# =========================
cat <<'PHP' > $MODULE_PATH/Models/Donation.php
<?php

namespace App\Modules\Donations\Models;

use Illuminate\Database\Eloquent\Model;

class Donation extends Model
{
    protected $fillable = [
        'donor_id',
        'project_id',
        'amount',
        'currency',
        'status',
    ];
}
PHP

# =========================
# Migration
# =========================
TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)

cat <<PHP > $MODULE_PATH/Database/Migrations/${TIMESTAMP}_create_donations_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('donations', function (Blueprint \$table) {
            \$table->id();

            \$table->uuid('donor_id');
            \$table->foreignId('project_id')->constrained()->cascadeOnDelete();

            \$table->decimal('amount', 12, 2);
            \$table->string('currency', 3);

            \$table->enum('status', ['pending', 'confirmed', 'failed'])
                ->default('pending');

            \$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('donations');
    }
};
PHP

# =========================
# Command
# =========================
cat <<'PHP' > $MODULE_PATH/Application/Commands/CreateDonationCommand.php
<?php

namespace App\Modules\Donations\Application\Commands;

class CreateDonationCommand
{
    public function __construct(
        public readonly string $donorId,
        public readonly int $projectId,
        public readonly float $amount,
        public readonly string $currency
    ) {}
}
PHP

# =========================
# Event
# =========================
cat <<'PHP' > $MODULE_PATH/Domain/Events/DonationCreated.php
<?php

namespace App\Modules\Donations\Domain\Events;

class DonationCreated
{
    public function __construct(
        public readonly int $donationId,
        public readonly int $projectId,
        public readonly float $amount,
        public readonly string $currency
    ) {}
}
PHP

# =========================
# Handler
# =========================
cat <<'PHP' > $MODULE_PATH/Application/Handlers/CreateDonationHandler.php
<?php

namespace App\Modules\Donations\Application\Handlers;

use App\Modules\Donations\Application\Commands\CreateDonationCommand;
use App\Modules\Donations\Models\Donation;
use App\Modules\Donations\Domain\Events\DonationCreated;
use Illuminate\Support\Facades\Event;

class CreateDonationHandler
{
    public function handle(CreateDonationCommand $command): Donation
    {
        $donation = Donation::create([
            'donor_id' => $command->donorId,
            'project_id' => $command->projectId,
            'amount' => $command->amount,
            'currency' => $command->currency,
            'status' => 'pending',
        ]);

        Event::dispatch(
            new DonationCreated(
                $donation->id,
                $donation->project_id,
                $donation->amount,
                $donation->currency
            )
        );

        return $donation;
    }
}
PHP

# =========================
# Controller
# =========================
cat <<'PHP' > $MODULE_PATH/Controllers/DonationController.php
<?php

namespace App\Modules\Donations\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Modules\Donations\Application\Commands\CreateDonationCommand;
use App\Modules\Donations\Application\Handlers\CreateDonationHandler;

class DonationController extends Controller
{
    public function store(Request $request, CreateDonationHandler $handler)
    {
        $data = $request->validate([
            'donor_id' => 'required|uuid',
            'project_id' => 'required|exists:projects,id',
            'amount' => 'required|numeric|min:1',
            'currency' => 'required|string|size:3',
        ]);

        $donation = $handler->handle(
            new CreateDonationCommand(
                $data['donor_id'],
                $data['project_id'],
                $data['amount'],
                $data['currency']
            )
        );

        return response()->json([
            'success' => true,
            'donation_id' => $donation->id,
            'status' => $donation->status,
        ]);
    }
}
PHP

# =========================
# Routes
# =========================
cat <<'PHP' > $MODULE_PATH/Routes/api.php
<?php

use Illuminate\Support\Facades\Route;
use App\Modules\Donations\Controllers\DonationController;

Route::post('/donations', [DonationController::class, 'store']);
PHP

# =========================
# Service Provider
# =========================
cat <<'PHP' > $MODULE_PATH/Providers/DonationServiceProvider.php
<?php

namespace App\Modules\Donations\Providers;

use Illuminate\Support\ServiceProvider;

class DonationServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadRoutesFrom(__DIR__ . '/../Routes/api.php');
        $this->loadMigrationsFrom(__DIR__ . '/../Database/Migrations');
    }
}
PHP

# =========================
# Register Provider
# =========================
PROVIDERS_FILE="config/app.php"

if ! grep -q "DonationServiceProvider" "$PROVIDERS_FILE"; then
    sed -i "/providers => \[/a\\
        App\\\\Modules\\\\Donations\\\\Providers\\\\DonationServiceProvider::class," $PROVIDERS_FILE
fi

echo "✅ Donations Phase 3 Ready!"
echo "➡️ Run: php artisan migrate"
