<?php

namespace App\Modules\Zakat\Domain\Entities;

use App\Modules\Zakat\Domain\ValueObjects\Money;

final class Zakat
{
    public function __construct(
        public readonly string $id,
        public readonly string $ledgerEntryId,
        public readonly Money $amount
    ) {}
}
