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
