<?php

namespace App\Modules\Spending\Listeners;

use App\Modules\Spending\Domain\Events\SpendingApproved;
use App\Modules\Core\Domain\Aggregates\LedgerAggregate;
use App\Modules\Core\Domain\Entities\LedgerEntry;
use App\Modules\Shared\ValueObjects\Money as SharedMoney;

final class UpdateLedgerOnSpending
{
    public function __construct(
        private LedgerAggregate $ledger
    ) {}

    public function handle(SpendingApproved $event): void
    {
        $entry = [
            new LedgerEntry(
                'cash_account', 
                new SharedMoney($event->spending->amount->amount, $event->spending->amount->currency),
                true
            ),
            new LedgerEntry(
                'spending_account', 
                new SharedMoney($event->spending->amount->amount, $event->spending->amount->currency),
                false
            )
        ];

        $this->ledger->record($entry);
    }
}
