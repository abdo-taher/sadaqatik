<?php

namespace App\Modules\Projects\Providers;

use Illuminate\Support\ServiceProvider;

class ProjectServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadRoutesFrom(__DIR__ . '/../Routes/viewer.php');
        $this->loadMigrationsFrom(__DIR__ . '/../Database/Migrations');
    }
}
