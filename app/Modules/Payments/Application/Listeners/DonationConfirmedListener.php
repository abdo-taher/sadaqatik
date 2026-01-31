<?php
namespace App\Modules\Payments\Application\Listeners;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use App\Modules\Payments\Application\Commands\ProcessPaymentCommand;
use App\Modules\Payments\Application\Handlers\ProcessPaymentHandler;

class DonationConfirmedListener{
    protected ProcessPaymentHandler $handler;
    public function __construct(ProcessPaymentHandler $handler){ $this->handler=$handler; }
    public function handle(DonationConfirmed $event): void{
        $this->handler->handle(new ProcessPaymentCommand($event->donationId,$event->amount,$event->currency,'card'));
    }
}
