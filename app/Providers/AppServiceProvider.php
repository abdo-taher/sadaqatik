<?php

namespace App\Providers;

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\MessageBus\Async\QueueEventBus;
use App\Modules\Shared\MessageBus\InMemoryEventBus;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(EventBus::class, fn () => new QueueEventBus());

    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}

