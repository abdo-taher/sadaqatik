<?php

namespace App\Modules\Core\Domain\ValueObjects;

final class Money
{
    public float $amount;
    public string $currency;

    public function __construct(float $amount, string $currency)
    {
        $this->amount = $amount;
        $this->currency = strtoupper($currency);
    }
}
