<?php
namespace App\Modules\Dashboard\ReadModels;
use Illuminate\Database\Eloquent\Model;
class FinanceDashboard extends Model{
    protected $fillable=['module','event_type','reference_id','amount','currency','status'];
}
