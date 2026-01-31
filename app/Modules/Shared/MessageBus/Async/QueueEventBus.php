<?php

namespace App\Modules\Shared\MessageBus\Async;

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Shared\Jobs\DispatchDomainEventJob;

class QueueEventBus implements EventBus
{
    public function publish(DomainEvent $event): void
    {
        DispatchDomainEventJob::dispatch($event);
    }
}
