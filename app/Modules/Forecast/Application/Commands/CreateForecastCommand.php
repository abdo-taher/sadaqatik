<?php

namespace App\Modules\Forecast\Application\Commands;

use App\Modules\Forecast\Domain\Entities\BudgetForecast;
use App\Modules\Shared\Contracts\Command;

final class CreateForecastCommand implements Command
{
    public function __construct(
        public readonly BudgetForecast $forecast
    ) {}
}
