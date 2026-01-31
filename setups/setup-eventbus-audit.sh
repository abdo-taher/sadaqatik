#!/bin/bash

echo "🔥 Setting up EventBus + Audit Pipeline..."

SHARED=app/Modules/Shared

# =========================
# 1️⃣ Ensure Directories
# =========================
mkdir -p $SHARED/{Contracts,Events,MessageBus,Audit}

# =========================
# 2️⃣ DomainEvent Base
# =========================
cat <<'PHP' > $SHARED/Events/DomainEvent.php
<?php

namespace App\Modules\Shared\Events;

use DateTimeImmutable;
use Ramsey\Uuid\Uuid;

abstract class DomainEvent
{
    public readonly string $eventId;
    public readonly DateTimeImmutable $occurredAt;

    public function __construct()
    {
        $this->eventId = Uuid::uuid4()->toString();
        $this->occurredAt = new DateTimeImmutable();
    }
}
PHP

# =========================
# 3️⃣ EventBus Contract
# =========================
cat <<'PHP' > $SHARED/Contracts/EventBus.php
<?php

namespace App\Modules\Shared\Contracts;

use App\Modules\Shared\Events\DomainEvent;

interface EventBus
{
    public function publish(DomainEvent $event): void;
}
PHP

# =========================
# 4️⃣ InMemory EventBus
# =========================
cat <<'PHP' > $SHARED/MessageBus/InMemoryEventBus.php
<?php

namespace App\Modules\Shared\MessageBus;

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Events\DomainEvent;

class InMemoryEventBus implements EventBus
{
    public function publish(DomainEvent $event): void
    {
        event($event);
    }
}
PHP

# =========================
# 5️⃣ Audit Listener
# =========================
cat <<'PHP' > $SHARED/Audit/AuditEventListener.php
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
PHP

# =========================
# 6️⃣ Audit Migration
# =========================
mkdir -p database/migrations/audit

cat <<'PHP' > database/migrations/audit/2026_01_01_000000_create_audit_logs_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->uuid('event_id')->index();
            $table->string('event_type');
            $table->json('payload');
            $table->timestamp('occurred_at');
            $table->timestamp('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
PHP

# =========================
# 7️⃣ Bind EventBus in AppServiceProvider
# =========================
APP_PROVIDER=app/Providers/AppServiceProvider.php

if ! grep -q "EventBus::class" $APP_PROVIDER; then
cat <<'PHP' >> $APP_PROVIDER

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\MessageBus\InMemoryEventBus;

public function register(): void
{
    $this->app->singleton(EventBus::class, fn () => new InMemoryEventBus());
}
PHP
fi

# =========================
# 8️⃣ Bind Audit Listener Globally
# =========================
EVENT_PROVIDER=app/Providers/EventServiceProvider.php

if ! grep -q "AuditEventListener" $EVENT_PROVIDER; then
sed -i "/protected \$listen = \[/a\\
        \\App\\\\Modules\\\\Shared\\\\Events\\\\DomainEvent::class => [\\\\App\\\\Modules\\\\Shared\\\\Audit\\\\AuditEventListener::class],
" $EVENT_PROVIDER
fi

# =========================
# 9️⃣ Enforcement Helper
# =========================
cat <<'PHP' > $SHARED/Events/EnforcesAudit.php
<?php

namespace App\Modules\Shared\Events;

trait EnforcesAudit
{
    final public function __construct()
    {
        parent::__construct();
    }
}
PHP

echo "✅ EventBus + Audit Pipeline READY"
echo "🚨 RULE: Publish events ONLY via EventBus"
