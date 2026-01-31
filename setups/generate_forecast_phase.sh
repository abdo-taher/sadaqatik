#!/bin/bash

echo "📊 Setting up FORECAST / BUDGET MODULE (Phase 6)..."

FORECAST=app/Modules/Forecast

# =========================
# 1️⃣ Directories
# =========================
mkdir -p $FORECAST/{Domain/{Entities,ValueObjects,Events},Application/{Commands,Handlers},Infrastructure/{Persistence/{Models,Migrations}},Listeners,Providers}

# =========================
# 2️⃣ Migration
# =========================
cat <<'PHP' > $FORECAST/Infrastructure/Persistence/Migrations/2026_01_01_060000_create_forecast_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('budget_forecasts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('project_id')->nullable();
            $table->uuid('committee_id')->nullable();
            $table->decimal('forecasted_income', 15, 2)->default(0);
            $table->decimal('forecasted_expense', 15, 2)->default(0);
            $table->decimal('budget_threshold', 15, 2)->default(0);
            $table->string('currency', 3)->default('EGP');
            $table->uuid('event_id');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('budget_forecasts');
    }
};
PHP

# =========================
# 3️⃣ Value Object (Money)
# =========================
cat <<'PHP' > $FORECAST/Domain/ValueObjects/Money.php
<?php

namespace App\Modules\Forecast\Domain\ValueObjects;

final class Money
{
    public function __construct(
        public readonly float $amount,
        public readonly string $currency = 'EGP'
    ) {}
}
PHP

# =========================
# 4️⃣ Entity (BudgetForecast)
# =========================
cat <<'PHP' > $FORECAST/Domain/Entities/BudgetForecast.php
<?php

namespace App\Modules\Forecast\Domain\Entities;

use App\Modules\Forecast\Domain\ValueObjects\Money;

final class BudgetForecast
{
    public function __construct(
        public readonly string $id,
        public readonly ?string $projectId = null,
        public readonly ?string $committeeId = null,
        public readonly Money $forecastedIncome,
        public readonly Money $forecastedExpense,
        public readonly Money $budgetThreshold
    ) {}
}
PHP

# =========================
# 5️⃣ Domain Event
# =========================
cat <<'PHP' > $FORECAST/Domain/Events/BudgetForecastCreated.php
<?php

namespace App\Modules\Forecast\Domain\Events;

use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Forecast\Domain\Entities\BudgetForecast;

final class BudgetForecastCreated extends DomainEvent
{
    public function __construct(
        public readonly BudgetForecast $forecast
    ) {
        parent::__construct();
    }
}
PHP

# =========================
# 6️⃣ Command
# =========================
cat <<'PHP' > $FORECAST/Application/Commands/CreateForecastCommand.php
<?php

namespace App\Modules\Forecast\Application\Commands;

use App\Modules\Forecast\Domain\Entities\BudgetForecast;
use App\Modules\Shared\Contracts\Command;

final class CreateForecastCommand implements Command
{
    public function __construct(
        public readonly BudgetForecast $forecast
    ) {}
}
PHP

# =========================
# 7️⃣ Command Handler
# =========================
cat <<'PHP' > $FORECAST/Application/Handlers/CreateForecastHandler.php
<?php

namespace App\Modules\Forecast\Application\Handlers;

use App\Modules\Forecast\Application\Commands\CreateForecastCommand;
use App\Modules\Forecast\Domain\Events\BudgetForecastCreated;
use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Phase\Phase;
use App\Modules\Shared\Phase\PhaseGuard;
use Illuminate\Support\Facades\DB;

final class CreateForecastHandler
{
    public function __construct(
        private EventBus $eventBus,
        private PhaseGuard $phaseGuard
    ) {}

    public function handle(CreateForecastCommand $command): void
    {
        $this->phaseGuard->ensureCompleted(Phase::SPENDING);

        DB::table('budget_forecasts')->insert([
            'id' => $command->forecast->id,
            'project_id' => $command->forecast->projectId,
            'committee_id' => $command->forecast->committeeId,
            'forecasted_income' => $command->forecast->forecastedIncome->amount,
            'forecasted_expense' => $command->forecast->forecastedExpense->amount,
            'budget_threshold' => $command->forecast->budgetThreshold->amount,
            'currency' => $command->forecast->forecastedIncome->currency,
            'event_id' => $command->forecast->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->eventBus->publish(
            new BudgetForecastCreated($command->forecast)
        );
    }
}
PHP

# =========================
# 8️⃣ Listener (Update Forecast on Ledger Events)
# =========================
cat <<'PHP' > $FORECAST/Listeners/UpdateForecastOnLedgerEvents.php
<?php

namespace App\Modules\Forecast\Listeners;

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Core\Domain\Events\LedgerEntryRecorded;
use Illuminate\Support\Facades\DB;

final class UpdateForecastOnLedgerEvents
{
    public function handle(LedgerEntryRecorded $event): void
    {
        foreach ($event->entries as $entry) {
            DB::table('budget_forecasts')
                ->where('project_id', $entry->projectId ?? null)
                ->increment('forecasted_expense', $entry->amount->amount);
        }
    }
}
PHP

# =========================
# 9️⃣ Service Provider
# =========================
cat <<'PHP' > $FORECAST/Providers/ForecastServiceProvider.php
<?php

namespace App\Modules\Forecast\Providers;

use Illuminate\Support\ServiceProvider;

final class ForecastServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../Infrastructure/Persistence/Migrations');
    }
}
PHP

echo "✅ Forecast / Budget Module (Phase 6) READY"
echo "📌 Run: php artisan migrate"
echo "📌 Make sure Queue Worker is running for async events"
