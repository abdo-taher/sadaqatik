<?php
namespace App\Modules\Spending\Application\Listeners;
use App\Modules\Spending\Domain\Events\SpendingCreated;
use App\Modules\Core\Ledger\Models\LedgerEntry;
class SpendingCreatedListener{
    public function handle(SpendingCreated $event): void{
        // Double Entry: Expense / Project Fund
        LedgerEntry::create([
            'reference_type'=>'Spending',
            'reference_id'=>$event->spendingId,
            'account_debit'=>'Project Expense',
            'account_credit'=>'Project Fund',
            'amount'=>$event->amount,
            'currency'=>'EGP',
            'status'=>'posted',
        ]);
    }
}
