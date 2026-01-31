<?php
namespace App\Modules\Dashboard\ReadModels;
use Illuminate\Database\Eloquent\Model;
class AuditorDashboard extends Model{
    protected $fillable=['module','event_type','payload','user_id','created_at'];
}
