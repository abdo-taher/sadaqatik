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

