<?php
namespace App\Modules\Allocation\Application\Listeners;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Core\Ledger\Models\LedgerEntry;
class AllocationCreatedListener{
    public function handle(AllocationCreated $event): void{
        LedgerEntry::create([
            'reference_type'=>'Allocation',
            'reference_id'=>$event->allocationId,
            'account_debit'=>'Project Fund',
            'account_credit'=>'Donations Revenue',
            'amount'=>$event->amount,
            'currency'=>'EGP',
            'status'=>'posted',
        ]);
    }
}
