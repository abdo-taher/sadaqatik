<?php

namespace App\Modules\Audit\Application\Handlers;

use App\Modules\Audit\Application\Commands\LogAuditCommand;
use App\Modules\Audit\Domain\Events\AuditLogged;
use App\Modules\Shared\Contracts\EventBus;
use Illuminate\Support\Facades\DB;

final class LogAuditHandler
{
    public function __construct(
        private EventBus $eventBus
    ) {}

    public function handle(LogAuditCommand $command): void
    {
        DB::table('audit_logs')->insert([
            'id' => $command->auditLog->id,
            'module' => $command->auditLog->module,
            'event_type' => $command->auditLog->eventType,
            'payload' => json_encode($command->auditLog->payload),
            'event_id' => $command->auditLog->eventId,
            'created_at' => $command->auditLog->createdAt,
        ]);

        $this->eventBus->publish(
            new AuditLogged($command->auditLog)
        );
    }
}
