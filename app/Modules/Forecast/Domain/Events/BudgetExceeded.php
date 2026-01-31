<?php
namespace App\Modules\Forecast\Domain\Events;
class BudgetExceeded {
    public function __construct(public readonly int $projectId, public readonly float $amount, public readonly string $type) {}
}
