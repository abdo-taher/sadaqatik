<?php
namespace App\Modules\Zakat\Models;
use Illuminate\Database\Eloquent\Model;
class Zakat extends Model {
    protected $fillable=['reference_type','reference_id','amount','status'];
}
