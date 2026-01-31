<?php

namespace App\Modules\Dashboard\Infrastructure\ReadModels;

use Illuminate\Database\Eloquent\Model;

class LedgerBalance extends Model
{
    protected $table = 'ledger_balances';

    public $timestamps = false;

    protected $fillable = [
        'account_id',
        'balance',
        'currency'
    ];
}
