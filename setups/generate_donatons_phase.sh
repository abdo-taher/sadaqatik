#!/bin/bash

echo "💸 Setting up DONATIONS MODULE (Phase 3)..."

DONATIONS=app/Modules/Donations

# =========================
# 1️⃣ Directories
# =========================
mkdir -p $DONATIONS/{Domain/{Entities,ValueObjects,Events},Application/{Commands,Handlers},Infrastructure/{Persistence/{Models,Migrations}},Listeners,Providers}

# =========================
# 2️⃣ Migration
# =========================
cat <<'PHP' > $DONATIONS/Infrastructure/Persistence/Migrations/2026_01_01_030000_create_donations_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('donations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('donor_name');
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
        Schema::dropIfExists('donations');
    }
};
PHP

# =========================
# 3️⃣ Value Object (Money)
# =========================
cat <<'PHP' > $DONATIONS/Domain/ValueObjects/Money.php
<?php

namespace App\Modules\Donations\Domain\ValueObjects;

final class Money
{
    public function __construct(
        public readonly float $amount,
        public readonly string $currency = 'EGP'
    ) {}
}
PHP

# =========================
# 4️⃣ Entity (Donation)
# =========================
cat <<'PHP' > $DONATIONS/Domain/Entities/Donation.php
<?php

namespace App\Modules\Donations\Domain\Entities;

use App\Modules\Donations\Domain\ValueObjects\Money;

final class Donation
{
    public function __construct(
        public readonly string $id,
        public readonly string $donorName,
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
cat <<'PHP' > $DONATIONS/Domain/Events/DonationCreated.php
<?php

namespace App\Modules\Donations\Domain\Events;

use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Donations\Domain\Entities\Donation;

final class DonationCreated extends DomainEvent
{
    public function __construct(
        public readonly Donation $donation
    ) {
        parent::__construct();
    }
}
PHP

# =========================
# 6️⃣ Command
# =========================
cat <<'PHP' > $DONATIONS/Application/Commands/CreateDonationCommand.php
<?php

namespace App\Modules\Donations\Application\Commands;

use App\Modules\Donations\Domain\Entities\Donation;
use App\Modules\Shared\Contracts\Command;

final class CreateDonationCommand implements Command
{
    public function __construct(
        public readonly Donation $donation
    ) {}
}
PHP

# =========================
# 7️⃣ Command Handler
# =========================
cat <<'PHP' > $DONATIONS/Application/Handlers/CreateDonationHandler.php
<?php

namespace App\Modules\Donations\Application\Handlers;

use App\Modules\Donations\Application\Commands\CreateDonationCommand;
use App\Modules\Donations\Domain\Events\DonationCreated;
use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Phase\Phase;
use App\Modules\Shared\Phase\PhaseGuard;
use Illuminate\Support\Facades\DB;

final class CreateDonationHandler
{
    public function __construct(
        private EventBus $eventBus,
        private PhaseGuard $phaseGuard
    ) {}

    public function handle(CreateDonationCommand $command): void
    {
        $this->phaseGuard->ensureCompleted(Phase::LEDGER);

        // Persist donation
        DB::table('donations')->insert([
            'id' => $command->donation->id,
            'donor_name' => $command->donation->donorName,
            'amount' => $command->donation->amount->amount,
            'currency' => $command->donation->amount->currency,
            'project_id' => $command->donation->projectId,
            'committee_id' => $command->donation->committeeId,
            'status' => $command->donation->status,
            'event_id' => $command->donation->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Emit Domain Event
        $this->eventBus->publish(
            new DonationCreated($command->donation)
        );
    }
}
PHP

# =========================
# 8️⃣ Listener (Update Ledger on Donation)
# =========================
cat <<'PHP' > $DONATIONS/Listeners/UpdateLedgerOnDonation.php
<?php

namespace App\Modules\Donations\Listeners;

use App\Modules\Donations\Domain\Events\DonationCreated;
use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Core\Domain\Aggregates\LedgerAggregate;
use App\Modules\Core\Domain\Entities\LedgerEntry;
use App\Modules\Shared\ValueObjects\Money as SharedMoney;

final class UpdateLedgerOnDonation
{
    public function __construct(
        private LedgerAggregate $ledger
    ) {}

    public function handle(DonationCreated $event): void
    {
        $entry = [
            new LedgerEntry(
                'donation_account', 
                new SharedMoney($event->donation->amount->amount, $event->donation->amount->currency),
                true
            ),
            new LedgerEntry(
                'cash_account', 
                new SharedMoney($event->donation->amount->amount, $event->donation->amount->currency),
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
cat <<'PHP' > $DONATIONS/Providers/DonationsServiceProvider.php
<?php

namespace App\Modules\Donations\Providers;

use Illuminate\Support\ServiceProvider;

final class DonationsServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../Infrastructure/Persistence/Migrations');
    }
}
PHP

echo "✅ Donations Module (Phase 3) READY"
echo "📌 Run: php artisan migrate"
echo "📌 Make sure Queue Worker is running for async events"
