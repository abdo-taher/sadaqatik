<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Route;

class ModuleRoutesServiceProvider extends ServiceProvider
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
            $path = base_path("app/Modules/{$module}/Presentation/Http/Routes");
            if (is_dir($path)) {
                // Load all PHP files inside the Routes directory
                foreach (glob($path . '/*.php') as $routeFile) {
                    require $routeFile;
                }
            }
        }
    }
}
