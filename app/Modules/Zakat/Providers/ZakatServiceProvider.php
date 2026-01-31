<?php
namespace App\Modules\Zakat\Providers;
use Illuminate\Support\ServiceProvider;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Zakat\Application\Listeners\DonationConfirmedListener;
use App\Modules\Zakat\Application\Listeners\AllocationCreatedListener;
use Illuminate\Support\Facades\Event;

class ZakatServiceProvider extends ServiceProvider{
    public function boot(): void{
        $this->loadMigrationsFrom(__DIR__.'/../Database/Migrations');
        Event::listen(DonationConfirmed::class,[DonationConfirmedListener::class,'handle']);
        Event::listen(AllocationCreated::class,[AllocationCreatedListener::class,'handle']);
    }
}
