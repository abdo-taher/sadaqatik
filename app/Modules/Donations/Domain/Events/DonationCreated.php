<?php

namespace App\Modules\Donations\Domain\Events;

use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Donations\Domain\Entities\Donation;

final class DonationCreated extends DomainEvent
{
    public function __construct(
        public readonly Donation $donation
    ) {
        parent::__construct();
    }
}
