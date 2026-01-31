<?php

namespace App\Modules\Forecast\Application\Handlers;

use App\Modules\Forecast\Application\Commands\CreateForecastCommand;
use App\Modules\Forecast\Domain\Events\BudgetForecastCreated;
use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Phase\Phase;
use App\Modules\Shared\Phase\PhaseGuard;
use Illuminate\Support\Facades\DB;

final class CreateForecastHandler
{
    public function __construct(
        private EventBus $eventBus,
        private PhaseGuard $phaseGuard
    ) {}

    public function handle(CreateForecastCommand $command): void
    {
        $this->phaseGuard->ensureCompleted(Phase::SPENDING);

        DB::table('budget_forecasts')->insert([
            'id' => $command->forecast->id,
            'project_id' => $command->forecast->projectId,
            'committee_id' => $command->forecast->committeeId,
            'forecasted_income' => $command->forecast->forecastedIncome->amount,
            'forecasted_expense' => $command->forecast->forecastedExpense->amount,
            'budget_threshold' => $command->forecast->budgetThreshold->amount,
            'currency' => $command->forecast->forecastedIncome->currency,
            'event_id' => $command->forecast->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->eventBus->publish(
            new BudgetForecastCreated($command->forecast)
        );
    }
}
