#!/bin/bash

echo "🚀 Setting up ASYNC EventBus (Queue + RabbitMQ Ready)..."

SHARED=app/Modules/Shared

# =========================
# 1️⃣ Directories
# =========================
mkdir -p $SHARED/{MessageBus/Async,Jobs,Idempotency,Correlation}

# =========================
# 2️⃣ Correlation ID
# =========================
cat <<'PHP' > $SHARED/Correlation/CorrelationId.php
<?php

namespace App\Modules\Shared\Correlation;

use Ramsey\Uuid\Uuid;

final class CorrelationId
{
    public static function generate(): string
    {
        return Uuid::uuid4()->toString();
    }
}
PHP

# =========================
# 3️⃣ Extend DomainEvent
# =========================
cat <<'PHP' > $SHARED/Events/DomainEvent.php
<?php

namespace App\Modules\Shared\Events;

use DateTimeImmutable;
use Ramsey\Uuid\Uuid;
use App\Modules\Shared\Correlation\CorrelationId;

abstract class DomainEvent
{
    public readonly string $eventId;
    public readonly string $correlationId;
    public readonly DateTimeImmutable $occurredAt;

    public function __construct()
    {
        $this->eventId = Uuid::uuid4()->toString();
        $this->correlationId = CorrelationId::generate();
        $this->occurredAt = new DateTimeImmutable();
    }
}
PHP

# =========================
# 4️⃣ Async Event Job
# =========================
cat <<'PHP' > $SHARED/Jobs/DispatchDomainEventJob.php
<?php

namespace App\Modules\Shared\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use App\Modules\Shared\Events\DomainEvent;

class DispatchDomainEventJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public DomainEvent $event
    ) {}

    public function handle(): void
    {
        event($this->event);
    }
}
PHP

# =========================
# 5️⃣ Async EventBus
# =========================
cat <<'PHP' > $SHARED/MessageBus/Async/QueueEventBus.php
<?php

namespace App\Modules\Shared\MessageBus\Async;

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Events\DomainEvent;
use App\Modules\Shared\Jobs\DispatchDomainEventJob;

class QueueEventBus implements EventBus
{
    public function publish(DomainEvent $event): void
    {
        DispatchDomainEventJob::dispatch($event);
    }
}
PHP

# =========================
# 6️⃣ RabbitMQ Adapter (Ready)
# =========================
cat <<'PHP' > $SHARED/MessageBus/Async/RabbitMQEventBus.php
<?php

namespace App\Modules\Shared\MessageBus\Async;

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\Events\DomainEvent;

/**
 * Placeholder for real RabbitMQ implementation
 * Swap implementation without touching business logic
 */
class RabbitMQEventBus implements EventBus
{
    public function publish(DomainEvent $event): void
    {
        // publish to exchange
        // routing key = event class
    }
}
PHP

# =========================
# 7️⃣ Idempotency Skeleton
# =========================
cat <<'PHP' > $SHARED/Idempotency/IdempotentConsumer.php
<?php

namespace App\Modules\Shared\Idempotency;

use Illuminate\Support\Facades\Cache;

trait IdempotentConsumer
{
    protected function alreadyProcessed(string $eventId): bool
    {
        return Cache::has("event:$eventId");
    }

    protected function markProcessed(string $eventId): void
    {
        Cache::put("event:$eventId", true, now()->addDays(7));
    }
}
PHP

# =========================
# 8️⃣ Switch EventBus Binding
# =========================
APP_PROVIDER=app/Providers/AppServiceProvider.php

sed -i "/EventBus::class/d" $APP_PROVIDER

cat <<'PHP' >> $APP_PROVIDER

use App\Modules\Shared\Contracts\EventBus;
use App\Modules\Shared\MessageBus\Async\QueueEventBus;

public function register(): void
{
    $this->app->singleton(EventBus::class, fn () => new QueueEventBus());
}
PHP

echo "✅ ASYNC EVENT BUS READY"
echo "📌 Next: php artisan queue:table && php artisan migrate"
echo "📌 Run worker: php artisan queue:work"
