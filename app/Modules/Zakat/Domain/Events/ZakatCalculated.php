<?php
namespace App\Modules\Zakat\Domain\Events;
class ZakatCalculated {
    public function __construct(public readonly string $referenceType,public readonly int $referenceId,public readonly float $amount) {}
}
