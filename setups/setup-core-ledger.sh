#!/bin/bash

echo "💰 Setting up CORE LEDGER MODULE (Phase 1 – Double Entry)..."

CORE=app/Modules/Core

# =========================
# 1️⃣ Directories
# =========================
mkdir -p $CORE/{Domain/{Aggregates,Entities,ValueObjects,Events},Application/{Commands,Handlers},Infrastructure/Persistence/{Models,Migrations,Repositories},Providers}

# =========================
# 2️⃣ Value Objects
# =========================
cat <<'PHP' > $CORE/Domain/ValueObjects/AccountType.php
<?php

namespace App\Modules\Core\Domain\ValueObjects;

enum AccountType: string
{
    case ASSET = 'asset';
    case LIABILITY = 'liability';
    case EQUITY = 'equity';
    case INCOME = 'income';
    case EXPENSE = 'expense';
}
PHP

# =========================
# 3️⃣ Ledger Account Entity
# =========================
cat <<'PHP' > $CORE/Domain/Entities/LedgerAccount.php
<?php

namespace App\Modules\Core\Domain\Entities;

use App\Modules\Core\Domain\ValueObjects\AccountType;

final class LedgerAccount
{
    public function __construct(
        public readonly string $id,
        public readonly string $name,
        public readonly AccountType $type
    ) {}
}
PHP

# =========================
# 4️⃣ Ledger Entry Entity
# =========================
cat <<'PHP' > $CORE/Domain/Entities/LedgerEntry.php
<?php

namespace App\Modules\Core\Domain\Entities;

use App\Modules\Shared\ValueObjects\Money;

final class LedgerEntry
{
    public function __construct(
        public readonly string $accountId,
        public readonly Money $amount,
        public readonly bool $isDebit
    ) {}
}
PHP

# =========================
# 5️⃣ Ledger Aggregate
# =========================
cat <<'PHP' > $CORE/Domain/Aggregates/LedgerAggregate.php
<?php

namespace App\Modules\Core\Domain\Aggregates;

use App\Modules\Core\Domain\Entities\LedgerEntry;
use App\Modules\Core\Domain\Events\LedgerEntryRecorded;
use App\Modules\Shared\Contracts\EventBus;

final class LedgerAggregate
{
    public function __construct(
        private EventBus $eventBus
    ) {}

    public function record(array $entries): void
    {
        $debits = 0;
        $credits = 0;

        foreach ($entries as $entry) {
            $entry->isDebit
                ? $debits += $entry->amount->amount
                : $credits += $entry->amount->amount;
        }

        if ($debits !== $credits) {
            throw new \RuntimeException('Ledger not balanced');
        }

        $this->eventBus->publish(
            new LedgerEntryRecorded($entries)
        );
    }
}
PHP

# =========================
# 6️⃣ Domain Event
# =========================
cat <<'PHP' > $CORE/Domain/Events/LedgerEntryRecorded.php
<?php

namespace App\Modules\Core\Domain\Events;

use App\Modules\Shared\Events\DomainEvent;

final class LedgerEntryRecorded extends DomainEvent
{
    public function __construct(
        public readonly array $entries
    ) {
        parent::__construct();
    }
}
PHP

# =========================
# 7️⃣ Command
# =========================
cat <<'PHP' > $CORE/Application/Commands/RecordLedgerEntryCommand.php
<?php

namespace App\Modules\Core\Application\Commands;

use App\Modules\Shared\Contracts\Command;

final class RecordLedgerEntryCommand implements Command
{
    public function __construct(
        public readonly array $entries
    ) {}
}
PHP

# =========================
# 8️⃣ Command Handler
# =========================
cat <<'PHP' > $CORE/Application/Handlers/RecordLedgerEntryHandler.php
<?php

namespace App\Modules\Core\Application\Handlers;

use App\Modules\Core\Application\Commands\RecordLedgerEntryCommand;
use App\Modules\Core\Domain\Aggregates\LedgerAggregate;
use App\Modules\Shared\Phase\Phase;
use App\Modules\Shared\Phase\PhaseGuard;

final class RecordLedgerEntryHandler
{
    public function __construct(
        private LedgerAggregate $ledger,
        private PhaseGuard $phaseGuard
    ) {}

    public function handle(RecordLedgerEntryCommand $command): void
    {
        $this->phaseGuard->ensureCompleted(Phase::LEDGER);

        $this->ledger->record($command->entries);
    }
}
PHP

# =========================
# 9️⃣ Ledger Tables
# =========================
cat <<'PHP' > $CORE/Infrastructure/Persistence/Migrations/2026_01_01_010000_create_ledger_tables.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ledger_accounts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('type');
        });

        Schema::create('ledger_entries', function (Blueprint $table) {
            $table->id();
            $table->uuid('account_id');
            $table->decimal('amount', 15, 2);
            $table->boolean('is_debit');
            $table->uuid('event_id');
            $table->timestamp('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ledger_entries');
        Schema::dropIfExists('ledger_accounts');
    }
};
PHP

echo "✅ CORE LEDGER MODULE READY"
echo "🚨 RULE: No money moves without LedgerEntryRecorded event"
