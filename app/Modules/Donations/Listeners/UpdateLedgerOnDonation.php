<?php

namespace App\Modules\Donations\Listeners;

use App\Modules\Donations\Domain\Events\DonationCreated;
use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Core\Domain\Aggregates\LedgerAggregate;
use App\Modules\Core\Domain\Entities\LedgerEntry;
use App\Modules\Shared\ValueObjects\Money as SharedMoney;

final class UpdateLedgerOnDonation
{
    public function __construct(
        private LedgerAggregate $ledger
    ) {}

    public function handle(DonationCreated $event): void
    {
        $entry = [
            new LedgerEntry(
                'donation_account', 
                new SharedMoney($event->donation->amount->amount, $event->donation->amount->currency),
                true
            ),
            new LedgerEntry(
                'cash_account', 
                new SharedMoney($event->donation->amount->amount, $event->donation->amount->currency),
                false
            )
        ];

        $this->ledger->record($entry);
    }
}
