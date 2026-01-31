<?php
namespace App\Modules\Dashboard\ReadModels;
use Illuminate\Database\Eloquent\Model;
class CommitteeDashboard extends Model{
    protected $fillable=['committee_id','allocation_id','project_id','amount','status'];
}
