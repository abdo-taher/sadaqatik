<?php
namespace App\Modules\Zakat\Application\Commands;
class CalculateZakatCommand {
    public function __construct(public readonly string $referenceType,public readonly int $referenceId,public readonly float $amount) {}
}
