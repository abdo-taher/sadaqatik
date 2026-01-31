<?php
namespace App\Modules\Forecast\Providers;
use Illuminate\Support\ServiceProvider;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Spending\Domain\Events\SpendingCreated;
use App\Modules\Forecast\Application\Listeners\AllocationCreatedListener;
use App\Modules\Forecast\Application\Listeners\SpendingCreatedListener;
use Illuminate\Support\Facades\Event;

class ForecastServiceProvider extends ServiceProvider{
    public function boot(): void{
        $this->loadMigrationsFrom(__DIR__.'/../Database/Migrations');
        Event::listen(AllocationCreated::class,[AllocationCreatedListener::class,'handle']);
        Event::listen(SpendingCreated::class,[SpendingCreatedListener::class,'handle']);
    }
}
