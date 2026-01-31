<?php
namespace App\Modules\Forecast\Domain\Events;
class ForecastChecked {
    public function __construct(public readonly int $projectId, public readonly float $allocated, public readonly float $spent, public readonly float $budget) {}
}
