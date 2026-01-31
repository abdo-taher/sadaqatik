<?php
namespace App\Modules\Forecast\Application\Commands;
class CheckBudgetCommand {
    public function __construct(public readonly int $projectId, public readonly float $amount, public readonly string $type) {}
}
