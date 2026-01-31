<?php

namespace App\Modules\Audit\Domain\Events;

use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Audit\Domain\Entities\AuditLog;

final class AuditLogged extends DomainEvent
{
    public function __construct(
        public readonly AuditLog $auditLog
    ) {
        parent::__construct();
    }
}
