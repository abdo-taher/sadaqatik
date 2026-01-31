<?php

namespace App\Modules\Core\Domain\Entities;

use App\Modules\Core\Domain\ValueObjects\AccountType;

final class LedgerAccount
{
    public function __construct(
        public readonly string $id,
        public readonly string $name,
        public readonly AccountType $type
    ) {}
}
