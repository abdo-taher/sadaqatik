<?php

use Illuminate\Support\Facades\Route;
use App\Modules\Allocation\Controllers\AllocationController;

Route::post('/allocations', [AllocationController::class, 'store']);
