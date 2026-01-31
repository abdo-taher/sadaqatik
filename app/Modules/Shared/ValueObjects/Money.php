<?php

namespace App\Modules\Shared\ValueObjects;

final class Money
{
    public function __construct(
        public readonly float $amount,
        public readonly string $currency
    ) {
        if ($amount < 0) {
            throw new \InvalidArgumentException('Money cannot be negative');
        }
    }
}
