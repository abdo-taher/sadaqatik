<?php

namespace App\Modules\Donations\Application\Handlers;

use App\Modules\Donations\Application\Commands\CreateDonationCommand;
use App\Modules\Donations\Domain\Events\DonationCreated;
use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Phase\Phase;
use App\Modules\Shared\Phase\PhaseGuard;
use Illuminate\Support\Facades\DB;

final class CreateDonationHandler
{
    public function __construct(
        private EventBus $eventBus,
        private PhaseGuard $phaseGuard
    ) {}

    public function handle(CreateDonationCommand $command): void
    {
        $this->phaseGuard->ensureCompleted(Phase::LEDGER);

        // Persist donation
        DB::table('donations')->insert([
            'id' => $command->donation->id,
            'donor_name' => $command->donation->donorName,
            'amount' => $command->donation->amount->amount,
            'currency' => $command->donation->amount->currency,
            'project_id' => $command->donation->projectId,
            'committee_id' => $command->donation->committeeId,
            'status' => $command->donation->status,
            'event_id' => $command->donation->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Emit Domain Event
        $this->eventBus->publish(
            new DonationCreated($command->donation)
        );
    }
}
