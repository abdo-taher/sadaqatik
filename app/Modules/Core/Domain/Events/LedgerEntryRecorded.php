<?php

namespace App\Modules\Core\Domain\Events;

use App\Modules\Shared\Events\DomainEvent;

final class LedgerEntryRecorded extends DomainEvent
{
    public function __construct(
        public readonly array $entries
    ) {
        parent::__construct();
    }
}
