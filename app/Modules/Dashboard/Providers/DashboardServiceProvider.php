<?php
namespace App\Modules\Dashboard\Providers;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Event;
use App\Modules\Dashboard\Application\Listeners\EventProjectionListener;

class DashboardServiceProvider extends ServiceProvider{
    public function boot(): void{
        Event::listen('*',[EventProjectionListener::class,'handle']);
    }
}
