<?php

namespace App\Modules\Shared\MessageBus\Async;

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Events\DomainEvent;

/**
 * Placeholder for real RabbitMQ implementation
 * Swap implementation without touching business logic
 */
class RabbitMQEventBus implements EventBus
{
    public function publish(DomainEvent $event): void
    {
        // publish to exchange
        // routing key = event class
    }
}
