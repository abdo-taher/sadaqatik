#!/bin/bash

echo "📝 Setting up AUDIT MODULE (Phase 8)..."

AUDIT=app/Modules/Audit

# =========================
# 1️⃣ Directories
# =========================
mkdir -p $AUDIT/{Domain/{Entities,Events},Application/{Commands,Handlers},Infrastructure/Persistence/{Models,Migrations},Listeners,Providers}

# =========================
# 2️⃣ Migration
# =========================
cat <<'PHP' > $AUDIT/Infrastructure/Persistence/Migrations/2026_01_01_080000_create_audit_logs_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('module');
            $table->string('event_type');
            $table->json('payload');
            $table->uuid('event_id');
            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
PHP

# =========================
# 2️⃣ model
# =========================
cat <<'PHP' > $AUDIT/Infrastructure/Persistence/Models/AuditLogModel.php
<?php

namespace App\Modules\Audit\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

final class AuditLogModel extends Model
{
    use HasUuids;

    protected $table = 'audit_logs';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    public $timestamps = false;

    protected $fillable = [
        'id',
        'module',
        'event_type',
        'payload',
        'event_id',
        'created_at',
    ];

    protected $casts = [
        'payload' => 'array',
    ];
}

PHP

# =========================
# 3️⃣ Entity (AuditLog)
# =========================
cat <<'PHP' > $AUDIT/Domain/Entities/AuditLog.php
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
PHP

# =========================
# 4️⃣ Domain Event
# =========================
cat <<'PHP' > $AUDIT/Domain/Events/AuditLogged.php
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
PHP

# =========================
# 5️⃣ Command
# =========================
cat <<'PHP' > $AUDIT/Application/Commands/LogAuditCommand.php
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
PHP

# =========================
# 6️⃣ Command Handler
# =========================
cat <<'PHP' > $AUDIT/Application/Handlers/LogAuditHandler.php
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
PHP

# =========================
# 7️⃣ Listener (Capture All Events)
# =========================
cat <<'PHP' > $AUDIT/Listeners/CaptureAllEvents.php
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
PHP

# =========================
# 8️⃣ Service Provider
# =========================
cat <<'PHP' > $AUDIT/Providers/AuditServiceProvider.php
<?php

namespace App\Modules\Audit\Providers;

use Illuminate\Support\ServiceProvider;

final class AuditServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../Infrastructure/Persistence/Migrations');
    }
}
PHP

echo "✅ Audit Module (Phase 8) READY"
echo "📌 Run: php artisan migrate"
echo "📌 Make sure Queue Worker is running for async events"
