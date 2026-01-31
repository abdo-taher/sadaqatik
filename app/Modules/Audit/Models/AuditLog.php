<?php
namespace App\Modules\Audit\Models;
use Illuminate\Database\Eloquent\Model;

class AuditLog extends Model {
    protected $fillable=['event_type','payload','user_id','module','created_at'];
    public $timestamps=false; // managed manually
}
