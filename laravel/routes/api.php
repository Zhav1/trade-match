<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ExploreController;

Route::middleware('auth:sanctum')->group(function () {
	Route::get('/explore', [ExploreController::class, 'getFeed']);
	Route::post('/like/{item}', [\App\Http\Controllers\LikeController::class, 'store']);

	// Chat routes: fetch history and send messages for a match
	Route::get('/chat/{match}/messages', [\App\Http\Controllers\ChatController::class, 'getMessages']);
	Route::post('/chat/{match}/messages', [\App\Http\Controllers\ChatController::class, 'sendMessage']);
});

