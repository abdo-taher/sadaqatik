<?php

namespace App\Modules\Organizations\Models;

use Illuminate\Database\Eloquent\Model;

class Organization extends Model
{
    protected $fillable = [
        'name',
        'description',
        'license_number',
        'status',
        'is_public',
    ];

    /* ================= Relations ================= */

    public function projects()
    {
        return $this->hasMany(\App\Modules\Projects\Models\Project::class);
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
