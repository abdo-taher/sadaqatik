<?php

namespace App\Modules\Forecast\Providers;

use Illuminate\Support\ServiceProvider;

final class ForecastServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../Infrastructure/Persistence/Migrations');
    }
}
