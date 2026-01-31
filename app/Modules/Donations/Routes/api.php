<?php
use Illuminate\Support\Facades\Route;
use App\Modules\Donations\Controllers\DonationController;
Route::post('/donations',[DonationController::class,'store']);
