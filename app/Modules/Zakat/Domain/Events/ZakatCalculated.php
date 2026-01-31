<?php

namespace App\Modules\Zakat\Domain\Events;

use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Zakat\Domain\Entities\Zakat;

final class ZakatCalculated extends DomainEvent
{
    public function __construct(
        public readonly Zakat $zakat
    ) {
        parent::__construct();
    }
}
