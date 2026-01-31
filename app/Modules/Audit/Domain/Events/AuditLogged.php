<?php
namespace App\Modules\Audit\Domain\Events;
class AuditLogged
{
    public function __construct(public readonly array $payload, public readonly ?string $userId, public readonly string $module, public readonly string $eventType) {}
}
