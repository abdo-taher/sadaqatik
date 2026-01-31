<?php
namespace App\Modules\Zakat\Application\Listeners;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use App\Modules\Zakat\Application\Commands\CalculateZakatCommand;
use App\Modules\Zakat\Application\Handlers\CalculateZakatHandler;

class DonationConfirmedListener{
    protected CalculateZakatHandler $handler;
    public function __construct(CalculateZakatHandler $handler){ $this->handler=$handler; }
    public function handle(DonationConfirmed $event): void{
        $this->handler->handle(new CalculateZakatCommand('donation',$event->donationId,$event->amount));
    }
}
