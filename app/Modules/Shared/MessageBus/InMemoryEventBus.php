<?php

namespace App\Modules\Shared\MessageBus;

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Events\DomainEvent;

class InMemoryEventBus implements EventBus
{
    public function publish(DomainEvent $event): void
    {
        event($event);
    }
}
