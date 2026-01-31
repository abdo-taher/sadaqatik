<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Viewer\HomeController;
use App\Http\Controllers\Viewer\OrganizationController;
use App\Http\Controllers\Viewer\ProjectController;

Route::prefix('viewer')->group(function () {

    Route::get('/home', [HomeController::class, 'index']);

    Route::get('/organizations', [OrganizationController::class, 'index']);
    Route::get('/organizations/{id}', [OrganizationController::class, 'show']);
    Route::get('/organizations/{id}/projects', [OrganizationController::class, 'projects']);

    Route::get('/projects', [ProjectController::class, 'index']);
    Route::get('/projects/{id}', [ProjectController::class, 'show']);
});
