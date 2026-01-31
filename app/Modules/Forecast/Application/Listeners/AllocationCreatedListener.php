<?php
namespace App\Modules\Forecast\Application\Listeners;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Forecast\Application\Commands\CheckBudgetCommand;
use App\Modules\Forecast\Application\Handlers\CheckBudgetHandler;

class AllocationCreatedListener{
    protected CheckBudgetHandler $handler;
    public function __construct(CheckBudgetHandler $handler){ $this->handler=$handler; }
    public function handle(AllocationCreated $event): void{
        $this->handler->handle(new CheckBudgetCommand($event->projectId,$event->amount,'allocation'));
    }
}
