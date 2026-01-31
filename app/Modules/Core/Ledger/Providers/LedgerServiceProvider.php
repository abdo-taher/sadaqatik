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
