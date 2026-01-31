<?php

namespace App\Modules\Zakat\Listeners;

use App\Modules\Zakat\Domain\Events\ZakatCalculated;
use App\Modules\Core\Domain\Aggregates\LedgerAggregate;
use App\Modules\Core\Domain\Entities\LedgerEntry;
use App\Modules\Shared\ValueObjects\Money as SharedMoney;

final class UpdateLedgerOnZakat
{
    public function __construct(
        private LedgerAggregate $ledger
    ) {}

    public function handle(ZakatCalculated $event): void
    {
        $entry = [
            new LedgerEntry(
                'zakat_payable',
                new SharedMoney($event->zakat->amount->amount, $event->zakat->amount->currency),
                true
            ),
            new LedgerEntry(
                'cash_account',
                new SharedMoney($event->zakat->amount->amount, $event->zakat->amount->currency),
                false
            )
        ];

        $this->ledger->record($entry);
    }
}
