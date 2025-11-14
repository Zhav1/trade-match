<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ExploreController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ItemController;

use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ImageUploadController;

// Public authentication routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    // Auth route that requires authentication
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Item management routes
    Route::apiResource('items', ItemController::class);
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::post('/upload/image', [ImageUploadController::class, 'upload']);
    
    // Explore and swipe routes
	Route::get('/explore', [ExploreController::class, 'getFeed']);
	Route::post('/swipe', [\App\Http\Controllers\SwipeController::class, 'store']);

	// Chat routes: fetch history and send messages for a match
	Route::get('/chat/{match}/messages', [\App\Http\Controllers\ChatController::class, 'getMessages']);
	Route::post('/chat/{match}/messages', [\App\Http\Controllers\ChatController::class, 'sendMessage']);
	Route::post('/chat/{match}/messages/{message}/agree', [\App\Http\Controllers\ChatController::class, 'agreeToLocation']);

    Route::get('/matches', [\App\Http\Controllers\BarterMatchController::class, 'index']);
	// Trade confirmation route
	Route::post('/trade/{match}/confirm', [\App\Http\Controllers\TradeController::class, 'confirmTrade']);
});

