<?php

namespace App\Modules\Donations\Domain\ValueObjects;

final class Money
{
    public function __construct(
        public readonly float $amount,
        public readonly string $currency = 'EGP'
    ) {}
}
