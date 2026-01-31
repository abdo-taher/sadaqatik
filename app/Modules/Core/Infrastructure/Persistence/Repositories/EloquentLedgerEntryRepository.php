<?php


namespace App\Modules\Core\Infrastructure\Persistence\Repositories;

use App\Modules\Core\Domain\Entities\LedgerEntry;
use Illuminate\Support\Facades\DB;

final class EloquentLedgerEntryRepository
{
    public function save(LedgerEntry $entry): void
    {
        DB::table('ledger_entries')->insert([
            'id' => $entry->id,
            'account_id' => $entry->accountId,
            'amount' => $entry->amount->amount,
            'currency' => $entry->amount->currency,
            'type' => $entry->type,
            'description' => $entry->description,
            'created_at' => $entry->createdAt,
        ]);
    }
}
