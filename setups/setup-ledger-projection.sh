#!/bin/bash

echo "📊 Setting up LEDGER BALANCE PROJECTION (Read Model)..."

DASHBOARD=app/Modules/Dashboard

# =========================
# 1️⃣ Directories
# =========================
mkdir -p $DASHBOARD/{Projections,Listeners,Infrastructure/{ReadModels,Migrations}}

# =========================
# 2️⃣ Balance Read Model
# =========================
cat <<'PHP' > $DASHBOARD/Infrastructure/ReadModels/LedgerBalance.php
<?php

namespace App\Modules\Dashboard\Infrastructure\ReadModels;

use Illuminate\Database\Eloquent\Model;

class LedgerBalance extends Model
{
    protected $table = 'ledger_balances';

    public $timestamps = false;

    protected $fillable = [
        'account_id',
        'balance',
        'currency'
    ];
}
PHP

# =========================
# 3️⃣ Projection Listener
# =========================
cat <<'PHP' > $DASHBOARD/Listeners/UpdateLedgerBalance.php
<?php

namespace App\Modules\Dashboard\Listeners;

use App\Modules\Core\Domain\Events\LedgerEntryRecorded;
use App\Modules\Shared\Idempotency\IdempotentConsumer;
use App\Modules\Dashboard\Infrastructure\ReadModels\LedgerBalance;

class UpdateLedgerBalance
{
    use IdempotentConsumer;

    public function handle(LedgerEntryRecorded $event): void
    {
        if ($this->alreadyProcessed($event->eventId)) {
            return;
        }

        foreach ($event->entries as $entry) {

            $balance = LedgerBalance::firstOrCreate(
                [
                    'account_id' => $entry->accountId,
                    'currency'   => $entry->amount->currency,
                ],
                [
                    'balance' => 0,
                ]
            );

            $amount = $entry->amount->amount;

            $balance->balance += $entry->isDebit
                ? $amount
                : -$amount;

            $balance->save();
        }

        $this->markProcessed($event->eventId);
    }
}
PHP

# =========================
# 4️⃣ Projection Migration
# =========================
cat <<'PHP' > $DASHBOARD/Infrastructure/Migrations/2026_01_01_020000_create_ledger_balances_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ledger_balances', function (Blueprint $table) {
            $table->id();
            $table->uuid('account_id')->index();
            $table->decimal('balance', 15, 2);
            $table->string('currency', 3);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ledger_balances');
    }
};
PHP

# =========================
# 5️⃣ Bind Listener to Event
# =========================
EVENT_PROVIDER=app/Providers/EventServiceProvider.php

if ! grep -q "UpdateLedgerBalance" $EVENT_PROVIDER; then
sed -i "/protected \$listen = \[/a\\
        \\App\\\\Modules\\\\Core\\\\Domain\\\\Events\\\\LedgerEntryRecorded::class => [\\\\App\\\\Modules\\\\Dashboard\\\\Listeners\\\\UpdateLedgerBalance::class],
" $EVENT_PROVIDER
fi

echo "✅ LEDGER PROJECTION READY"
echo "📌 Run migrations: php artisan migrate"
echo "📌 Queue worker must be running"
