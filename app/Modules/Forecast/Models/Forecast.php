<?php
namespace App\Modules\Forecast\Models;
use Illuminate\Database\Eloquent\Model;
class Forecast extends Model {
    protected $fillable=['project_id','allocated','spent','budget'];
}
