<?php

namespace App\Modules\Organizations\Providers;

use Illuminate\Support\ServiceProvider;

class OrganizationServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadRoutesFrom(__DIR__ . '/../Routes/viewer.php');
        $this->loadMigrationsFrom(__DIR__ . '/../Database/Migrations');
    }
}
