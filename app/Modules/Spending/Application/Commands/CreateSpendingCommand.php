<?php
namespace App\Modules\Spending\Application\Commands;
class CreateSpendingCommand {
    public function __construct(public readonly int $allocationId,public readonly float $amount,public readonly string $spentBy,public readonly ?string $description=null) {}
}
