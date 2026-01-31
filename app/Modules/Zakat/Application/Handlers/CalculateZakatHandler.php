<?php

namespace App\Modules\Zakat\Application\Handlers;

use App\Modules\Zakat\Application\Commands\CalculateZakatCommand;
use App\Modules\Zakat\Domain\Events\ZakatCalculated;
use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Phase\Phase;
use App\Modules\Shared\Phase\PhaseGuard;
use Illuminate\Support\Facades\DB;

final class CalculateZakatHandler
{
    public function __construct(
        private EventBus $eventBus,
        private PhaseGuard $phaseGuard
    ) {}

    public function handle(CalculateZakatCommand $command): void
    {
        $this->phaseGuard->ensureCompleted(Phase::FORECAST);

        DB::table('zakat')->insert([
            'id' => $command->zakat->id,
            'ledger_entry_id' => $command->zakat->ledgerEntryId,
            'amount' => $command->zakat->amount->amount,
            'currency' => $command->zakat->amount->currency,
            'event_id' => $command->zakat->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->eventBus->publish(
            new ZakatCalculated($command->zakat)
        );
    }
}
