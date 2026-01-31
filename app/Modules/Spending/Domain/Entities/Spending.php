<?php

namespace App\Modules\Spending\Domain\Entities;

use App\Modules\Spending\Domain\ValueObjects\Money;

final class Spending
{
    public function __construct(
        public readonly string $id,
        public readonly string $description,
        public readonly Money $amount,
        public readonly ?string $projectId = null,
        public readonly ?string $committeeId = null,
        public string $status = 'pending'
    ) {}
}
