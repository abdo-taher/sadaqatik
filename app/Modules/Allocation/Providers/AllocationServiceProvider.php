<?php

namespace App\Modules\Allocation\Providers;

use Illuminate\Support\ServiceProvider;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Allocation\Application\Listeners\AllocationCreatedListener;
use Illuminate\Support\Facades\Event;

class AllocationServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadRoutesFrom(__DIR__ . '/../Routes/api.php');
        $this->loadMigrationsFrom(__DIR__ . '/../Database/Migrations');

        Event::listen(AllocationCreated::class, [AllocationCreatedListener::class, 'handle']);
    }
}
