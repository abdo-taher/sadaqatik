<?php
namespace App\Modules\Allocation\Models;
use Illuminate\Database\Eloquent\Model;
class Allocation extends Model { protected $fillable=['donation_id','project_id','amount','allocated_by','status']; }
