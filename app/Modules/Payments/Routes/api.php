<?php
use Illuminate\Support\Facades\Route;
use App\Modules\Payments\Controllers\PaymentController;
Route::post('/payment',[PaymentController::class,'pay']);
