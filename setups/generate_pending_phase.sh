#!/bin/bash

echo "💵 Setting up SPENDING MODULE (Phase 5)..."

SPENDING=app/Modules/Spending

# =========================
# 1️⃣ Directories
# =========================
mkdir -p $SPENDING/{Domain/{Entities,ValueObjects,Events},Application/{Commands,Handlers},Infrastructure/{Persistence/{Models,Migrations}},Listeners,Providers}

# =========================
# 2️⃣ Migration
# =========================
cat <<'PHP' > $SPENDING/Infrastructure/Persistence/Migrations/2026_01_01_050000_create_spending_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('spending', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('description');
            $table->decimal('amount', 15, 2);
            $table->string('currency', 3);
            $table->uuid('project_id')->nullable();
            $table->uuid('committee_id')->nullable();
            $table->string('status')->default('pending');
            $table->uuid('event_id');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('spending');
    }
};
PHP

# =========================
# 3️⃣ Value Object (Money)
# =========================
cat <<'PHP' > $SPENDING/Domain/ValueObjects/Money.php
<?php

namespace App\Modules\Spending\Domain\ValueObjects;

final class Money
{
    public function __construct(
        public readonly float $amount,
        public readonly string $currency = 'EGP'
    ) {}
}
PHP

# =========================
# 4️⃣ Entity (Spending)
# =========================
cat <<'PHP' > $SPENDING/Domain/Entities/Spending.php
<?php

namespace App\Modules\Spending\Domain\Entities;

use App\Modules\Spending\Domain\ValueObjects\Money;

final class Spending
{
    public function __construct(
        public readonly string $id,
        public readonly string $description,
        public readonly Money $amount,
        public readonly ?string $projectId = null,
        public readonly ?string $committeeId = null,
        public string $status = 'pending'
    ) {}
}
PHP

# =========================
# 5️⃣ Domain Event
# =========================
cat <<'PHP' > $SPENDING/Domain/Events/SpendingApproved.php
<?php

namespace App\Modules\Spending\Domain\Events;

use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Spending\Domain\Entities\Spending;

final class SpendingApproved extends DomainEvent
{
    public function __construct(
        public readonly Spending $spending
    ) {
        parent::__construct();
    }
}
PHP

# =========================
# 6️⃣ Command
# =========================
cat <<'PHP' > $SPENDING/Application/Commands/ApproveSpendingCommand.php
<?php

namespace App\Modules\Spending\Application\Commands;

use App\Modules\Spending\Domain\Entities\Spending;
use App\Modules\Shared\Contracts\Command;

final class ApproveSpendingCommand implements Command
{
    public function __construct(
        public readonly Spending $spending
    ) {}
}
PHP

# =========================
# 7️⃣ Command Handler
# =========================
cat <<'PHP' > $SPENDING/Application/Handlers/ApproveSpendingHandler.php
<?php

namespace App\Modules\Spending\Application\Handlers;

use App\Modules\Spending\Application\Commands\ApproveSpendingCommand;
use App\Modules\Spending\Domain\Events\SpendingApproved;
use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Phase\Phase;
use App\Modules\Shared\Phase\PhaseGuard;
use Illuminate\Support\Facades\DB;

final class ApproveSpendingHandler
{
    public function __construct(
        private EventBus $eventBus,
        private PhaseGuard $phaseGuard
    ) {}

    public function handle(ApproveSpendingCommand $command): void
    {
        $this->phaseGuard->ensureCompleted(Phase::DONATIONS);

        // Persist spending
        DB::table('spending')->insert([
            'id' => $command->spending->id,
            'description' => $command->spending->description,
            'amount' => $command->spending->amount->amount,
            'currency' => $command->spending->amount->currency,
            'project_id' => $command->spending->projectId,
            'committee_id' => $command->spending->committeeId,
            'status' => 'approved',
            'event_id' => $command->spending->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Emit Domain Event
        $this->eventBus->publish(
            new SpendingApproved($command->spending)
        );
    }
}
PHP

# =========================
# 8️⃣ Listener (Update Ledger on Spending)
# =========================
cat <<'PHP' > $SPENDING/Listeners/UpdateLedgerOnSpending.php
<?php

namespace App\Modules\Spending\Listeners;

use App\Modules\Spending\Domain\Events\SpendingApproved;
use App\Modules\Core\Domain\Aggregates\LedgerAggregate;
use App\Modules\Core\Domain\Entities\LedgerEntry;
use App\Modules\Shared\ValueObjects\Money as SharedMoney;

final class UpdateLedgerOnSpending
{
    public function __construct(
        private LedgerAggregate $ledger
    ) {}

    public function handle(SpendingApproved $event): void
    {
        $entry = [
            new LedgerEntry(
                'cash_account', 
                new SharedMoney($event->spending->amount->amount, $event->spending->amount->currency),
                true
            ),
            new LedgerEntry(
                'spending_account', 
                new SharedMoney($event->spending->amount->amount, $event->spending->amount->currency),
                false
            )
        ];

        $this->ledger->record($entry);
    }
}
PHP

# =========================
# 9️⃣ Service Provider
# =========================
cat <<'PHP' > $SPENDING/Providers/SpendingServiceProvider.php
<?php

namespace App\Modules\Spending\Providers;

use Illuminate\Support\ServiceProvider;

final class SpendingServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../Infrastructure/Persistence/Migrations');
    }
}
PHP

echo "✅ Spending Module (Phase 5) READY"
echo "📌 Run: php artisan migrate"
echo "📌 Make sure Queue Worker is running for async events"
