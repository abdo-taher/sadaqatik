<?php

namespace App\Modules\Audit\Providers;

use Illuminate\Support\ServiceProvider;

final class AuditServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../Infrastructure/Persistence/Migrations');
    }
}
