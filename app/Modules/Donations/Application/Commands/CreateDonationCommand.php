<?php

namespace App\Modules\Donations\Application\Commands;

use App\Modules\Donations\Domain\Entities\Donation;
use App\Modules\Shared\Contracts\Command;

final class CreateDonationCommand implements Command
{
    public function __construct(
        public readonly Donation $donation
    ) {}
}
