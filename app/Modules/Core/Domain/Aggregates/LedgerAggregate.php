<?php

namespace App\Modules\Core\Domain\Aggregates;

use App\Modules\Core\Domain\Entities\LedgerEntry;
use App\Modules\Core\Domain\Events\LedgerEntryRecorded;
use App\Modules\Shared\Contracts\EventBus;

final class LedgerAggregate
{
    public function __construct(
        private EventBus $eventBus
    ) {}

    public function record(array $entries): void
    {
        $debits = 0;
        $credits = 0;

        foreach ($entries as $entry) {
            $entry->isDebit
                ? $debits += $entry->amount->amount
                : $credits += $entry->amount->amount;
        }

        if ($debits !== $credits) {
            throw new \RuntimeException('Ledger not balanced');
        }

        $this->eventBus->publish(
            new LedgerEntryRecorded($entries)
        );
    }
}
