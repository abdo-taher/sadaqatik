#!/bin/bash

echo "🚀 Building Enterprise Modular Foundation..."

BASE=app/Modules

MODULES=(
  Core
  Donations
  Payments
  Projects
  Committees
  Spending
  Finance
  Audit
  Dashboard
  Admin
  Shared
)

# -------------------------
# Create Modules Structure
# -------------------------
for MODULE in "${MODULES[@]}"; do
  echo "📦 Creating module: $MODULE"

  mkdir -p $BASE/$MODULE/{Domain/{Aggregates,Entities,ValueObjects,Events,Policies},Application/{Commands,Handlers,Services,DTOs,Listeners},Infrastructure/{Persistence/{Models,Repositories,Migrations},MessageBus,External},Presentation/Http/{Controllers,Requests,Routes},Providers,Config}
done

# -------------------------
# Shared Kernel
# -------------------------
echo "🧠 Creating Shared Kernel..."

mkdir -p $BASE/Shared/{Contracts,Events,MessageBus,ValueObjects,Security,Phase,Audit}

# Event Base
cat <<'PHP' > $BASE/Shared/Events/DomainEvent.php
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

# Event Bus Contract
cat <<'PHP' > $BASE/Shared/Contracts/EventBus.php
<?php

namespace App\Modules\Shared\Contracts;

use App\Modules\Shared\Events\DomainEvent;

interface EventBus
{
    public function publish(DomainEvent $event): void;
}
PHP

# Command Interface
cat <<'PHP' > $BASE/Shared/Contracts/Command.php
<?php

namespace App\Modules\Shared\Contracts;

interface Command {}
PHP

# Command Bus
cat <<'PHP' > $BASE/Shared/MessageBus/SimpleCommandBus.php
<?php

namespace App\Modules\Shared\MessageBus;

use App\Modules\Shared\Contracts\Command;

class SimpleCommandBus
{
    protected array $handlers = [];

    public function register(string $command, string $handler): void
    {
        $this->handlers[$command] = $handler;
    }

    public function dispatch(Command $command): mixed
    {
        $handler = app($this->handlers[$command::class]);
        return $handler->handle($command);
    }
}
PHP

# InMemory Event Bus
cat <<'PHP' > $BASE/Shared/MessageBus/InMemoryEventBus.php
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

# Money Value Object
cat <<'PHP' > $BASE/Shared/ValueObjects/Money.php
<?php

namespace App\Modules\Shared\ValueObjects;

final class Money
{
    public function __construct(
        public readonly float $amount,
        public readonly string $currency
    ) {
        if ($amount < 0) {
            throw new \InvalidArgumentException('Money cannot be negative');
        }
    }
}
PHP

# Phase Enum
cat <<'PHP' > $BASE/Shared/Phase/Phase.php
<?php

namespace App\Modules\Shared\Phase;

enum Phase: int
{
    case LEDGER = 1;
    case PROJECTS = 2;
    case DONATIONS = 3;
    case ALLOCATION = 4;
    case SPENDING = 5;
    case FORECAST = 6;
    case ZAKAT = 7;
    case AUDIT = 8;
    case PAYMENTS = 9;
    case TRACKING = 10;
}
PHP

# Phase Guard
cat <<'PHP' > $BASE/Shared/Phase/PhaseGuard.php
<?php

namespace App\Modules\Shared\Phase;

class PhaseGuard
{
    protected array $completed = [];

    public function markCompleted(Phase $phase): void
    {
        $this->completed[$phase->value] = true;
    }

    public function ensureCompleted(Phase ...$phases): void
    {
        foreach ($phases as $phase) {
            if (!($this->completed[$phase->value] ?? false)) {
                throw new \RuntimeException("Phase {$phase->name} not completed.");
            }
        }
    }
}
PHP

# -------------------------
# Audit Pipeline
# -------------------------
cat <<'PHP' > $BASE/Shared/Audit/AuditEventListener.php
<?php

namespace App\Modules\Shared\Audit;

use App\Modules\Shared\Events\DomainEvent;

class AuditEventListener
{
    public function handle(DomainEvent $event): void
    {
        // Persist immutable audit log (append-only)
        logger()->info('AUDIT_EVENT', [
            'event' => $event::class,
            'event_id' => $event->eventId,
            'occurred_at' => $event->occurredAt,
        ]);
    }
}
PHP

# -------------------------
# Module Base ServiceProvider
# -------------------------
cat <<'PHP' > app/Providers/ModuleServiceProvider.php
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class ModuleServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        foreach (glob(app_path('Modules/*/Providers/*ServiceProvider.php')) as $provider) {
            $class = $this->resolveClass($provider);
            $this->app->register($class);
        }
    }

    protected function resolveClass(string $path): string
    {
        $path = str_replace(app_path() . '/', '', $path);
        return 'App\\' . str_replace(['/', '.php'], ['\\', ''], $path);
    }
}
PHP

# -------------------------
# Final
# -------------------------
echo "✅ FOUNDATION READY"
echo "🚨 Next step: DO NOT write business logic yet."
