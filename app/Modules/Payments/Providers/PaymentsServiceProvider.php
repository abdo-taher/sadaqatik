<?php
namespace App\Modules\Payments\Providers;
use Illuminate\Support\ServiceProvider;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use App\Modules\Payments\Application\Listeners\DonationConfirmedListener;
use Illuminate\Support\Facades\Event;

class PaymentsServiceProvider extends ServiceProvider{
    public function boot(): void{
        $this->loadRoutesFrom(__DIR__.'/../Routes/api.php');
        $this->loadMigrationsFrom(__DIR__.'/../Database/Migrations');
        Event::listen(DonationConfirmed::class,[DonationConfirmedListener::class,'handle']);
    }
}
