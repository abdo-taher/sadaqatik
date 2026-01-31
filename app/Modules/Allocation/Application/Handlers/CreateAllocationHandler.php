<?php
namespace App\Modules\Allocation\Application\Handlers;
use App\Modules\Allocation\Application\Commands\CreateAllocationCommand;
use App\Modules\Allocation\Models\Allocation;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use Illuminate\Support\Facades\Event;
class CreateAllocationHandler{
    public function handle(CreateAllocationCommand $command): Allocation{
        $allocation=Allocation::create([
            'donation_id'=>$command->donationId,
            'project_id'=>$command->projectId,
            'amount'=>$command->amount,
            'allocated_by'=>$command->allocatedBy,
            'status'=>'completed',
        ]);
        Event::dispatch(new AllocationCreated($allocation->id,$allocation->donation_id,$allocation->project_id,$allocation->amount));
        return $allocation;
    }
}
