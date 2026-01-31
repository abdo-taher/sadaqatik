<?php

namespace App\Modules\Shared\Events;

use DateTimeImmutable;
use Ramsey\Uuid\Uuid;
use App\Modules\Shared\Correlation\CorrelationId;

abstract class DomainEvent
{
    public readonly string $eventId;
    public readonly string $correlationId;
    public readonly DateTimeImmutable $occurredAt;

    public function __construct()
    {
        $this->eventId = Uuid::uuid4()->toString();
        $this->correlationId = CorrelationId::generate();
        $this->occurredAt = new DateTimeImmutable();
    }
}
