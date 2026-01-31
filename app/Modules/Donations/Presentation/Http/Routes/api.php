<?php
use Illuminate\Support\Facades\Route;
use App\Modules\Donations\Presentation\Http\Controllers\Api\DonorController;
use App\Modules\Donations\Presentation\Http\Controllers\Api\ProjectController;

Route::prefix('api/donor')->group(function () {
    Route::get('projects', [ProjectController::class, 'index']);
    Route::post('donate', [DonorController::class, 'donate']);
});
