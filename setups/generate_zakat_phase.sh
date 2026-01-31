#!/bin/bash

echo "🕌 Setting up ZAKAT MODULE (Phase 7)..."

ZAKAT=app/Modules/Zakat

# =========================
# 1️⃣ Directories
# =========================
mkdir -p $ZAKAT/{Domain/{Entities,ValueObjects,Events},Application/{Commands,Handlers},Infrastructure/Persistence/{Models,Migrations},Listeners,Providers}

# =========================
# 2️⃣ Migration
# =========================
cat <<'PHP' > $ZAKAT/Infrastructure/Persistence/Migrations/2026_01_01_070000_create_zakat_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('zakat', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('ledger_entry_id');
            $table->decimal('amount', 15, 2);
            $table->string('currency', 3)->default('EGP');
            $table->uuid('event_id');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('zakat');
    }
};
PHP

# =========================
# 3️⃣ Value Object (Money)
# =========================
cat <<'PHP' > $ZAKAT/Domain/ValueObjects/Money.php
<?php

namespace App\Modules\Zakat\Domain\ValueObjects;

final class Money
{
    public function __construct(
        public readonly float $amount,
        public readonly string $currency = 'EGP'
    ) {}
}
PHP

# =========================
# 4️⃣ Entity (Zakat)
# =========================
cat <<'PHP' > $ZAKAT/Domain/Entities/Zakat.php
<?php

namespace App\Modules\Zakat\Domain\Entities;

use App\Modules\Zakat\Domain\ValueObjects\Money;

final class Zakat
{
    public function __construct(
        public readonly string $id,
        public readonly string $ledgerEntryId,
        public readonly Money $amount
    ) {}
}
PHP

# =========================
# 5️⃣ Domain Event
# =========================
cat <<'PHP' > $ZAKAT/Domain/Events/ZakatCalculated.php
<?php

namespace App\Modules\Zakat\Domain\Events;

use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Zakat\Domain\Entities\Zakat;

final class ZakatCalculated extends DomainEvent
{
    public function __construct(
        public readonly Zakat $zakat
    ) {
        parent::__construct();
    }
}
PHP

# =========================
# 6️⃣ Command
# =========================
cat <<'PHP' > $ZAKAT/Application/Commands/CalculateZakatCommand.php
<?php

namespace App\Modules\Zakat\Application\Commands;

use App\Modules\Zakat\Domain\Entities\Zakat;
use App\Modules\Shared\Contracts\Command;

final class CalculateZakatCommand implements Command
{
    public function __construct(
        public readonly Zakat $zakat
    ) {}
}
PHP

# =========================
# 7️⃣ Command Handler
# =========================
cat <<'PHP' > $ZAKAT/Application/Handlers/CalculateZakatHandler.php
<?php

namespace App\Modules\Zakat\Application\Handlers;

use App\Modules\Zakat\Application\Commands\CalculateZakatCommand;
use App\Modules\Zakat\Domain\Events\ZakatCalculated;
use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Phase\Phase;
use App\Modules\Shared\Phase\PhaseGuard;
use Illuminate\Support\Facades\DB;

final class CalculateZakatHandler
{
    public function __construct(
        private EventBus $eventBus,
        private PhaseGuard $phaseGuard
    ) {}

    public function handle(CalculateZakatCommand $command): void
    {
        $this->phaseGuard->ensureCompleted(Phase::FORECAST);

        DB::table('zakat')->insert([
            'id' => $command->zakat->id,
            'ledger_entry_id' => $command->zakat->ledgerEntryId,
            'amount' => $command->zakat->amount->amount,
            'currency' => $command->zakat->amount->currency,
            'event_id' => $command->zakat->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->eventBus->publish(
            new ZakatCalculated($command->zakat)
        );
    }
}
PHP

# =========================
# 8️⃣ Listener (Update Ledger on Zakat)
# =========================
cat <<'PHP' > $ZAKAT/Listeners/UpdateLedgerOnZakat.php
<?php

namespace App\Modules\Zakat\Listeners;

use App\Modules\Zakat\Domain\Events\ZakatCalculated;
use App\Modules\Core\Domain\Aggregates\LedgerAggregate;
use App\Modules\Core\Domain\Entities\LedgerEntry;
use App\Modules\Shared\ValueObjects\Money as SharedMoney;

final class UpdateLedgerOnZakat
{
    public function __construct(
        private LedgerAggregate $ledger
    ) {}

    public function handle(ZakatCalculated $event): void
    {
        $entry = [
            new LedgerEntry(
                'zakat_payable',
                new SharedMoney($event->zakat->amount->amount, $event->zakat->amount->currency),
                true
            ),
            new LedgerEntry(
                'cash_account',
                new SharedMoney($event->zakat->amount->amount, $event->zakat->amount->currency),
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
cat <<'PHP' > $ZAKAT/Providers/ZakatServiceProvider.php
<?php

namespace App\Modules\Zakat\Providers;

use Illuminate\Support\ServiceProvider;

final class ZakatServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../Infrastructure/Persistence/Migrations');
    }
}
PHP

echo "✅ Zakat Module (Phase 7) READY"
echo "📌 Run: php artisan migrate"
echo "📌 Make sure Queue Worker is running for async events"
