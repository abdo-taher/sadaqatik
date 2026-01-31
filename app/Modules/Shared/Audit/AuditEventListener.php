<?php

namespace App\Modules\Shared\Audit;

use App\Modules\Shared\Events\DomainEvent;
use Illuminate\Support\Facades\DB;

class AuditEventListener
{
    public function handle(DomainEvent $event): void
    {
        DB::table('audit_logs')->insert([
            'event_id'    => $event->eventId,
            'event_type'  => $event::class,
            'payload'     => json_encode($event),
            'occurred_at' => $event->occurredAt,
            'created_at'  => now(),
        ]);
    }
}
