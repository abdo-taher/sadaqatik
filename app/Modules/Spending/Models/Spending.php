<?php
namespace App\Modules\Spending\Models;
use Illuminate\Database\Eloquent\Model;
class Spending extends Model {
    protected $fillable=['allocation_id','amount','spent_by','description','status'];
}
