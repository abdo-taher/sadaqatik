#!/bin/bash

set -e

MODULE_PATH="app/Modules/Core/Ledger"

echo "🚀 Creating Ledger Module + Double Entry..."

# =========================
# Directories
# =========================
mkdir -p $MODULE_PATH/{Models,Domain/Events,Application/Listeners,Database/Migrations,Providers}

# =========================
# Model
# =========================
cat <<'PHP' > $MODULE_PATH/Models/LedgerEntry.php
<?php

namespace App\Modules\Core\Ledger\Models;

use Illuminate\Database\Eloquent\Model;

class LedgerEntry extends Model
{
    protected $fillable = [
        'reference_type',
        'reference_id',
        'account_debit',
        'account_credit',
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

cat <<PHP > $MODULE_PATH/Database/Migrations/${TIMESTAMP}_create_ledger_entries_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ledger_entries', function (Blueprint \$table) {
            \$table->id();

            \$table->string('reference_type');
            \$table->unsignedBigInteger('reference_id');

            \$table->string('account_debit');
            \$table->string('account_credit');

            \$table->decimal('amount', 14, 2);
            \$table->string('currency', 3);

            \$table->enum('status', ['pending', 'posted', 'failed'])->default('pending');

            \$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ledger_entries');
    }
};
PHP

# =========================
# Event Listener for DonationCreated
# =========================
cat <<'PHP' > $MODULE_PATH/Application/Listeners/DonationCreatedListener.php
<?php

namespace App\Modules\Core\Ledger\Application\Listeners;

use App\Modules\Donations\Domain\Events\DonationCreated;
use App\Modules\Core\Ledger\Models\LedgerEntry;

class DonationCreatedListener
{
    /**
     * Handle the event.
     */
    public function handle(DonationCreated $event): void
    {
        // Dummy Accounts: Donations Receivable / Donations Revenue
        LedgerEntry::create([
            'reference_type' => 'Donation',
            'reference_id' => $event->donationId,
            'account_debit' => 'Donations Receivable',
            'account_credit' => 'Donations Revenue',
            'amount' => $event->amount,
            'currency' => $event->currency,
            'status' => 'posted',
        ]);
    }
}
PHP

# =========================
# Service Provider
# =========================
cat <<'PHP' > $MODULE_PATH/Providers/LedgerServiceProvider.php
<?php

namespace App\Modules\Core\Ledger\Providers;

use Illuminate\Support\ServiceProvider;
use App\Modules\Donations\Domain\Events\DonationCreated;
use App\Modules\Core\Ledger\Application\Listeners\DonationCreatedListener;
use Illuminate\Support\Facades\Event;

class LedgerServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../Database/Migrations');

        // Register Event Listener
        Event::listen(DonationCreated::class, [DonationCreatedListener::class, 'handle']);
    }
}
PHP

# =========================
# Register Provider
# =========================
PROVIDERS_FILE="config/app.php"

if ! grep -q "LedgerServiceProvider" "$PROVIDERS_FILE"; then
    sed -i "/providers => \[/a\\
        App\\\\Modules\\\\Core\\\\Ledger\\\\Providers\\\\LedgerServiceProvider::class," $PROVIDERS_FILE
fi

echo "✅ Ledger + Double Entry ready!"
echo "➡️ Run: php artisan migrate"
echo "➡️ DonationsCreated Event now triggers LedgerEntry"
