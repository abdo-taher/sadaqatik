<?php
namespace App\Modules\Forecast\Application\Handlers;
use App\Modules\Forecast\Application\Commands\CheckBudgetCommand;
use App\Modules\Forecast\Models\Forecast;
use App\Modules\Forecast\Domain\Events\ForecastChecked;
use App\Modules\Forecast\Domain\Events\BudgetExceeded;
use Illuminate\Support\Facades\Event;

class CheckBudgetHandler{
    public function handle(CheckBudgetCommand $command): void{
        $forecast = Forecast::firstOrCreate(['project_id'=>$command->projectId],['budget'=>0,'allocated'=>0,'spent'=>0]);

        if($command->type==='allocation'){
            $newAllocated=$forecast->allocated + $command->amount;
            if($newAllocated > $forecast->budget){
                Event::dispatch(new BudgetExceeded($command->projectId,$command->amount,'allocation'));
                return;
            }
            $forecast->allocated = $newAllocated;
        }

        if($command->type==='spending'){
            $newSpent=$forecast->spent + $command->amount;
            if($newSpent > $forecast->budget){
                Event::dispatch(new BudgetExceeded($command->projectId,$command->amount,'spending'));
                return;
            }
            $forecast->spent = $newSpent;
        }

        $forecast->save();
        Event::dispatch(new ForecastChecked($forecast->project_id,$forecast->allocated,$forecast->spent,$forecast->budget));
    }
}
