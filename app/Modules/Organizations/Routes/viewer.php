<?php

use Illuminate\Support\Facades\Route;
use App\Modules\Organizations\Controllers\Viewer\OrganizationViewerController;

Route::prefix('organizations')->group(function () {
    Route::get('/', [OrganizationViewerController::class, 'index']);
    Route::get('{id}', [OrganizationViewerController::class, 'show']);
});
