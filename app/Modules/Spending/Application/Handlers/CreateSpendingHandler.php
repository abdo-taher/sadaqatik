<?php
namespace App\Modules\Spending\Application\Handlers;
use App\Modules\Spending\Application\Commands\CreateSpendingCommand;
use App\Modules\Spending\Models\Spending;
use App\Modules\Spending\Domain\Events\SpendingCreated;
use Illuminate\Support\Facades\Event;
class CreateSpendingHandler{
    public function handle(CreateSpendingCommand $command): Spending{
        $spending=Spending::create([
            'allocation_id'=>$command->allocationId,
            'amount'=>$command->amount,
            'spent_by'=>$command->spentBy,
            'description'=>$command->description,
            'status'=>'completed',
        ]);
        Event::dispatch(new SpendingCreated($spending->id,$spending->allocation_id,$spending->amount,$spending->spent_by,$spending->description));
        return $spending;
    }
}
