<?php
namespace App\Modules\Core\Ledger\Models;
use Illuminate\Database\Eloquent\Model;
class LedgerEntry extends Model{ protected $fillable=['reference_type','reference_id','account_debit','account_credit','amount','currency','status']; }
