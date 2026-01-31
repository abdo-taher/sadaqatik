<?php

namespace App\Modules\Core\Application\Handlers;

use App\Modules\Core\Application\Commands\RecordLedgerEntryCommand;
use App\Modules\Core\Domain\Aggregates\LedgerAggregate;
use App\Modules\Shared\Phase\Phase;
use App\Modules\Shared\Phase\PhaseGuard;

final class RecordLedgerEntryHandler
{
    public function __construct(
        private LedgerAggregate $ledger,
        private PhaseGuard $phaseGuard
    ) {}

    public function handle(RecordLedgerEntryCommand $command): void
    {
        $this->phaseGuard->ensureCompleted(Phase::LEDGER);

        $this->ledger->record($command->entries);
    }
}
