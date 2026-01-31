<?php

namespace App\Modules\Spending\Application\Handlers;

use App\Modules\Spending\Application\Commands\ApproveSpendingCommand;
use App\Modules\Spending\Domain\Events\SpendingApproved;
use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Phase\Phase;
use App\Modules\Shared\Phase\PhaseGuard;
use Illuminate\Support\Facades\DB;

final class ApproveSpendingHandler
{
    public function __construct(
        private EventBus $eventBus,
        private PhaseGuard $phaseGuard
    ) {}

    public function handle(ApproveSpendingCommand $command): void
    {
        $this->phaseGuard->ensureCompleted(Phase::DONATIONS);

        // Persist spending
        DB::table('spending')->insert([
            'id' => $command->spending->id,
            'description' => $command->spending->description,
            'amount' => $command->spending->amount->amount,
            'currency' => $command->spending->amount->currency,
            'project_id' => $command->spending->projectId,
            'committee_id' => $command->spending->committeeId,
            'status' => 'approved',
            'event_id' => $command->spending->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Emit Domain Event
        $this->eventBus->publish(
            new SpendingApproved($command->spending)
        );
    }
}
