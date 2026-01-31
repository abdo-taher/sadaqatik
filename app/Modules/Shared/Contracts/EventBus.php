<?php

namespace App\Modules\Shared\Contracts;

use App\Modules\Shared\Events\DomainEvent;

interface EventBus
{
    public function publish(DomainEvent $event): void;
}
