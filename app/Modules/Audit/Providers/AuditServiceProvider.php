<?php
namespace App\Modules\Audit\Providers;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Event;
use App\Modules\Audit\Application\Listeners\AuditListener;

class AuditServiceProvider extends ServiceProvider{
    public function boot(): void{
        $this->loadMigrationsFrom(__DIR__.'/../Database/Migrations');

        // Listen to all events dynamically
        Event::listen('*', [AuditListener::class,'handle']);
    }
}
