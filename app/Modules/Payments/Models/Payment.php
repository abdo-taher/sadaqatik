<?php
namespace App\Modules\Payments\Models;
use Illuminate\Database\Eloquent\Model;
class Payment extends Model {
    protected $fillable=['donation_id','amount','currency','payment_method','status'];
}
