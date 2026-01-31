<?php
namespace App\Modules\Spending\Domain\Events;
class SpendingCreated {
    public function __construct(public readonly int $spendingId,public readonly int $allocationId,public readonly float $amount,public readonly string $spentBy,public readonly ?string $description=null) {}
}
