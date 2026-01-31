<?php

namespace App\Modules\Forecast\Domain\Events;

use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Forecast\Domain\Entities\BudgetForecast;

final class BudgetForecastCreated extends DomainEvent
{
    public function __construct(
        public readonly BudgetForecast $forecast
    ) {
        parent::__construct();
    }
}
