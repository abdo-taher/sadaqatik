<?php

namespace App\Modules\Forecast\Domain\Entities;

use App\Modules\Forecast\Domain\ValueObjects\Money;

final class BudgetForecast
{
    public function __construct(
        public readonly string $id,
        public readonly ?string $projectId = null,
        public readonly ?string $committeeId = null,
        public readonly Money $forecastedIncome,
        public readonly Money $forecastedExpense,
        public readonly Money $budgetThreshold
    ) {}
}
