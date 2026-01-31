<?php

namespace App\Modules\Dashboard\Listeners;

use App\Modules\Core\Domain\Events\LedgerEntryRecorded;
use App\Modules\Shared\Idempotency\IdempotentConsumer;
use App\Modules\Dashboard\Infrastructure\ReadModels\LedgerBalance;

class UpdateLedgerBalance
{
    use IdempotentConsumer;

    public function handle(LedgerEntryRecorded $event): void
    {
        if ($this->alreadyProcessed($event->eventId)) {
            return;
        }

        foreach ($event->entries as $entry) {

            $balance = LedgerBalance::firstOrCreate(
                [
                    'account_id' => $entry->accountId,
                    'currency'   => $entry->amount->currency,
                ],
                [
                    'balance' => 0,
                ]
            );

            $amount = $entry->amount->amount;

            $balance->balance += $entry->isDebit
                ? $amount
                : -$amount;

            $balance->save();
        }

        $this->markProcessed($event->eventId);
    }
}
