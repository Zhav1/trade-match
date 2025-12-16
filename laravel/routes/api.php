<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ExploreController;
use App\Http\Controllers\ImageUploadController;
use App\Http\Controllers\ItemController;
use App\Http\Controllers\SwapController;
use App\Http\Controllers\SwipeController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\NotificationController;

// Public authentication routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/auth/google', [AuthController::class, 'googleLogin']);
Route::post('/auth/google/register', [AuthController::class, 'googleRegister']);

// All routes below require authentication
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'getAuthenticatedUser']); // As per GEMINI.md

    // User Profile Management
    Route::put('/user/profile', [UserController::class, 'updateProfile']);
    Route::post('/user/profile-picture', [UserController::class, 'uploadProfilePicture']);

    // Items & Categories
    Route::apiResource('items', ItemController::class);
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::post('/upload/image', [ImageUploadController::class, 'upload']);
    
    // Explore & Swipe (Core Loop)
	Route::get('/explore', [ExploreController::class, 'getFeed']);
	Route::post('/swipe', [SwipeController::class, 'store']);

	// Swaps, Chat, and Trade Confirmation
    Route::get('/swaps', [SwapController::class, 'index']);
    Route::get('/swaps/{swap}/messages', [SwapController::class, 'getMessages']);
    Route::post('/swaps/{swap}/messages', [SwapController::class, 'sendMessage']);
    Route::post('/swaps/{swap}/confirm', [SwapController::class, 'confirmTrade']);
    
    // Location Negotiation (as per GEMINI.md)
    Route::post('/swaps/{swap}/suggest-location', [SwapController::class, 'suggestLocation']);
    Route::post('/swaps/{swap}/accept-location', [SwapController::class, 'acceptLocation']);
    
    // Reviews (Stage 6)
    Route::get('/user/{userId}/reviews', [ReviewController::class, 'getUserReviews']);
    Route::post('/reviews', [ReviewController::class, 'store']);
    Route::get('/reviews/{id}', [ReviewController::class, 'show']);
    
    // Notifications (Stage 6)
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::put('/notifications/{id}/mark-read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/mark-all-read', [NotificationController::class, 'markAllAsRead']);
});
