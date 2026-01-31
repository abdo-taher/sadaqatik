<?php

namespace App\Modules\Audit\Listeners;

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Audit\Application\Handlers\LogAuditHandler;
use App\Modules\Audit\Application\Commands\LogAuditCommand;
use App\Modules\Audit\Domain\Entities\AuditLog;
use Illuminate\Support\Str;

final class CaptureAllEvents
{
    public function __construct(
        private LogAuditHandler $handler
    ) {}

    public function handle(DomainEvent $event): void
    {
        $audit = new AuditLog(
            id: (string) Str::uuid(),
            module: $event::class,
            eventType: get_class($event),
            payload: (array) $event,
            eventId: $event->id ?? (string) Str::uuid(),
            createdAt: now()->toDateTimeString()
        );

        $this->handler->handle(new LogAuditCommand($audit));
    }
}
