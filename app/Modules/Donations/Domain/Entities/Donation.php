<?php

namespace App\Modules\Donations\Domain\Entities;

use App\Modules\Donations\Domain\ValueObjects\Money;

final class Donation
{
    public function __construct(
        public readonly string $id,
        public readonly string $donorName,
        public readonly Money $amount,
        public readonly ?string $projectId = null,
        public readonly ?string $committeeId = null,
        public string $status = 'pending'
    ) {}
}
