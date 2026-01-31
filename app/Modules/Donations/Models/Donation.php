<?php
namespace App\Modules\Donations\Models;
use Illuminate\Database\Eloquent\Model;

class Donation extends Model {
    protected $fillable = ['donor_id','project_id','amount','currency','status'];
}
