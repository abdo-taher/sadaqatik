<?php

namespace App\Modules\Spending\Domain\Events;

use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Spending\Domain\Entities\Spending;

final class SpendingApproved extends DomainEvent
{
    public function __construct(
        public readonly Spending $spending
    ) {
        parent::__construct();
    }
}
