<?php

namespace App\Modules\Projects\Models;

use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    protected $fillable = [
        'organization_id',
        'title',
        'description',
        'target_amount',
        'current_amount',
        'status',
        'is_public',
    ];

    /* ================= Relations ================= */

    public function organization()
    {
        return $this->belongsTo(\App\Modules\Organizations\Models\Organization::class);
    }

    /* ================= Scopes ================= */

    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeVisible($query)
    {
        return $query->public()->active();
    }
}
