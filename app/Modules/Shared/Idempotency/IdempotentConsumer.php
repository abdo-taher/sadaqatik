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
