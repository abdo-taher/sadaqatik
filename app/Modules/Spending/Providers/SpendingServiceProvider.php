<?php

namespace App\Modules\Spending\Providers;

use Illuminate\Support\ServiceProvider;

final class SpendingServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../Infrastructure/Persistence/Migrations');
    }
}
