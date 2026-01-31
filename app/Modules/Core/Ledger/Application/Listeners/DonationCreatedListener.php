<?php

namespace App\Modules\Core\Ledger\Application\Listeners;

use App\Modules\Donations\Domain\Events\DonationCreated;
use App\Modules\Core\Ledger\Models\LedgerEntry;

class DonationCreatedListener
{
    /**
     * Handle the event.
     */
    public function handle(DonationCreated $event): void
    {
        // Dummy Accounts: Donations Receivable / Donations Revenue
        LedgerEntry::create([
            'reference_type' => 'Donation',
            'reference_id' => $event->donationId,
            'account_debit' => 'Donations Receivable',
            'account_credit' => 'Donations Revenue',
            'amount' => $event->amount,
            'currency' => $event->currency,
            'status' => 'posted',
        ]);
    }
}
