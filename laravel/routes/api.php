<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ExploreController;

Route::middleware('auth:sanctum')->group(function () {
	Route::get('/explore', [ExploreController::class, 'getFeed']);
	Route::post('/like/{item}', [\App\Http\Controllers\LikeController::class, 'store']);
});

