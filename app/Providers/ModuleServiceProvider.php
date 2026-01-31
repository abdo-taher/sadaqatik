<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class ModuleServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        foreach (glob(app_path('Modules/*/Providers/*ServiceProvider.php')) as $provider) {
            $class = $this->resolveClass($provider);
            $this->app->register($class);
        }
    }

    protected function resolveClass(string $path): string
    {
        $path = str_replace(app_path() . '/', '', $path);
        return 'App\\' . str_replace(['/', '.php'], ['\\', ''], $path);
    }
}
