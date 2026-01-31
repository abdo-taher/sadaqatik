<?php

namespace App\Modules\Zakat\Providers;

use Illuminate\Support\ServiceProvider;

final class ZakatServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../Infrastructure/Persistence/Migrations');
    }
}
