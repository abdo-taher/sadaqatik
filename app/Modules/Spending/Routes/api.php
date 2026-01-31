<?php
use Illuminate\Support\Facades\Route;
use App\Modules\Spending\Controllers\SpendingController;
Route::post('/spending',[SpendingController::class,'store']);
