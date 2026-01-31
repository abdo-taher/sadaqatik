<?php

namespace App\Modules\Zakat\Application\Commands;

use App\Modules\Zakat\Domain\Entities\Zakat;
use App\Modules\Shared\Contracts\Command;

final class CalculateZakatCommand implements Command
{
    public function __construct(
        public readonly Zakat $zakat
    ) {}
}
