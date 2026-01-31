<?php

namespace App\Modules\Forecast\Listeners;

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Core\Domain\Events\LedgerEntryRecorded;
use Illuminate\Support\Facades\DB;

final class UpdateForecastOnLedgerEvents
{
    public function handle(LedgerEntryRecorded $event): void
    {
        foreach ($event->entries as $entry) {
            DB::table('budget_forecasts')
                ->where('project_id', $entry->projectId ?? null)
                ->increment('forecasted_expense', $entry->amount->amount);
        }
    }
}
