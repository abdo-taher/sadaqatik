<?php
namespace App\Modules\Audit\Application\Listeners;
use App\Modules\Audit\Models\AuditLog;
use App\Modules\Audit\Domain\Events\AuditLogged;
use Illuminate\Support\Facades\Event;

class AuditListener
{
    public function handle(object $event): void {
        $payload = json_decode(json_encode($event), true);
        $userId = auth()->check() ? auth()->id() : null;
        $module = explode('\\', get_class($event))[2] ?? 'Unknown';
        $eventType = class_basename($event);

        AuditLog::create([
            'payload'=>$payload,
            'user_id'=>$userId,
            'module'=>$module,
            'event_type'=>$eventType,
        ]);

        Event::dispatch(new AuditLogged($payload, $userId, $module, $eventType));
    }
}
