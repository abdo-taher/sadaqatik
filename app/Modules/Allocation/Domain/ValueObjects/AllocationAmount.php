<?php
namespace App\Modules\Allocation\Domain\ValueObjects;

final class AllocationAmount
{
    public float $amount;
    public string $currency;

    public function __construct(float $amount, string $currency)
    {
        $this->amount = $amount;
        $this->currency = strtoupper($currency);
    }
}