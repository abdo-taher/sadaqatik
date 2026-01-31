<?php

namespace App\Modules\Forecast\Domain\ValueObjects;

final class Money
{
    public function __construct(
        public readonly float $amount,
        public readonly string $currency = 'EGP'
    ) {}
}
