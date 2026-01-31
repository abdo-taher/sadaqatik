<?php
namespace App\Modules\Dashboard\ReadModels;
use Illuminate\Database\Eloquent\Model;
class DonorDashboard extends Model{
    protected $fillable=['donor_id','donation_id','project_id','amount','currency','status'];
}
