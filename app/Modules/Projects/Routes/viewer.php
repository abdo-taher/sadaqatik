<?php

use Illuminate\Support\Facades\Route;
use App\Modules\Projects\Controllers\Viewer\ProjectViewerController;

Route::prefix('projects')->group(function () {
    Route::get('/', [ProjectViewerController::class, 'index']);
    Route::get('{id}', [ProjectViewerController::class, 'show']);
});
