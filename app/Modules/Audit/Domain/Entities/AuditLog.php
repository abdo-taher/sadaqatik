<?php

namespace App\Modules\Audit\Domain\Entities;

final class AuditLog
{
    public function __construct(
        public readonly string $id,
        public readonly string $module,
        public readonly string $eventType,
        public readonly array $payload,
        public readonly string $eventId,
        public readonly string $createdAt
    ) {}
}
