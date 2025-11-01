<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ExploreController;
use App\Http\Controllers\AuthController;

// Public authentication routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    // Auth route that requires authentication
    Route::post('/logout', [AuthController::class, 'logout']);
	Route::get('/explore', [ExploreController::class, 'getFeed']);
	Route::post('/like/{item}', [\App\Http\Controllers\LikeController::class, 'store']);

	// Chat routes: fetch history and send messages for a match
	Route::get('/chat/{match}/messages', [\App\Http\Controllers\ChatController::class, 'getMessages']);
	Route::post('/chat/{match}/messages', [\App\Http\Controllers\ChatController::class, 'sendMessage']);

	// Trade confirmation route
	Route::post('/trade/{match}/confirm', [\App\Http\Controllers\TradeController::class, 'confirmTrade']);
});

