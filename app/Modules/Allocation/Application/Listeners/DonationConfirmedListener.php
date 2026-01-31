<?php
namespace App\Modules\Allocation\Application\Listeners;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use App\Modules\Allocation\Application\Commands\CreateAllocationCommand;
use App\Modules\Allocation\Application\Handlers\CreateAllocationHandler;
class DonationConfirmedListener{
    protected CreateAllocationHandler $handler;
    public function __construct(CreateAllocationHandler $handler){ $this->handler=$handler; }
    public function handle(DonationConfirmed $event): void{
        $command=new CreateAllocationCommand($event->donationId,$event->projectId,$event->amount,'system');
        $this->handler->handle($command);
    }
}
