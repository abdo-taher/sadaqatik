<?php

namespace App\Modules\Shared\Phase;

enum Phase: int
{
    case LEDGER = 1;
    case PROJECTS = 2;
    case DONATIONS = 3;
    case ALLOCATION = 4;
    case SPENDING = 5;
    case FORECAST = 6;
    case ZAKAT = 7;
    case AUDIT = 8;
    case PAYMENTS = 9;
    case TRACKING = 10;
}
