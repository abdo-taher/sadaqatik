<?php
namespace App\Modules\Spending\Providers;
use Illuminate\Support\ServiceProvider;
use App\Modules\Spending\Domain\Events\SpendingCreated;
use App\Modules\Spending\Application\Listeners\SpendingCreatedListener;
use Illuminate\Support\Facades\Event;

class SpendingServiceProvider extends ServiceProvider {
    public function boot(): void{
        $this->loadRoutesFrom(__DIR__.'/../Routes/api.php');
        $this->loadMigrationsFrom(__DIR__.'/../Database/Migrations');
        Event::listen(SpendingCreated::class,[SpendingCreatedListener::class,'handle']);
    }
}
