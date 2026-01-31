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
