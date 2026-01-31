<?php
namespace App\Modules\Zakat\Application\Listeners;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Zakat\Application\Commands\CalculateZakatCommand;
use App\Modules\Zakat\Application\Handlers\CalculateZakatHandler;

class AllocationCreatedListener{
    protected CalculateZakatHandler $handler;
    public function __construct(CalculateZakatHandler $handler){ $this->handler=$handler; }
    public function handle(AllocationCreated $event): void{
        $this->handler->handle(new CalculateZakatCommand('allocation',$event->allocationId,$event->amount));
    }
}
