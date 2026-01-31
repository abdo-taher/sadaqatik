<?php
namespace App\Modules\Forecast\Application\Listeners;
use App\Modules\Spending\Domain\Events\SpendingCreated;
use App\Modules\Forecast\Application\Commands\CheckBudgetCommand;
use App\Modules\Forecast\Application\Handlers\CheckBudgetHandler;

class SpendingCreatedListener{
    protected CheckBudgetHandler $handler;
    public function __construct(CheckBudgetHandler $handler){ $this->handler=$handler; }
    public function handle(SpendingCreated $event): void{
        $this->handler->handle(new CheckBudgetCommand($event->allocationId,$event->amount,'spending'));
    }
}
