<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class ModuleMigrationServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $modules = [
            'Shared',
            'Core',
            'Dashboard',
            'Donations',
            'Payments',
            'Projects',
            'Committees',
            'Spending',
            'Finance',
            'Audit',
            'Admin',
        ];

        foreach ($modules as $module) {
            $path = base_path("app/Modules/{$module}/Infrastructure/Persistence/Migrations");
            if (is_dir($path)) {
                $this->loadMigrationsFrom($path);
            }
        }
    }
}
