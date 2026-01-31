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
