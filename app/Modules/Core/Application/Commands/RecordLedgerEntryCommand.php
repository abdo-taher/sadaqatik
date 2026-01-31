<?php

namespace App\Modules\Core\Application\Commands;

use App\Modules\Shared\Contracts\Command;

final class RecordLedgerEntryCommand implements Command
{
    public function __construct(
        public readonly array $entries
    ) {}
}
