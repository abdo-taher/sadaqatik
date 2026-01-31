<?php

namespace App\Modules\Audit\Application\Commands;

use App\Modules\Audit\Domain\Entities\AuditLog;
use App\Modules\Shared\Contracts\Command;

final class LogAuditCommand implements Command
{
    public function __construct(
        public readonly AuditLog $auditLog
    ) {}
}
