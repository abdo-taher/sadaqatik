<?php
namespace App\Modules\Donations\Application\Handlers;
use App\Modules\Donations\Application\Commands\CreateDonationCommand;
use App\Modules\Donations\Models\Donation;
use App\Modules\Donations\Domain\Events\DonationCreated;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use Illuminate\Support\Facades\Event;
class CreateDonationHandler {
    public function handle(CreateDonationCommand $command): Donation {
        $donation = Donation::create([
            'donor_id'=>$command->donorId,
            'project_id'=>$command->projectId,
            'amount'=>$command->amount,
            'currency'=>$command->currency,
            'status'=>'confirmed', // مباشرة Confirmed
        ]);
        Event::dispatch(new DonationCreated($donation->id,$donation->project_id,$donation->amount,$donation->currency));
        Event::dispatch(new DonationConfirmed($donation->id,$donation->project_id,$donation->amount,$donation->currency));
        return $donation;
    }
}
