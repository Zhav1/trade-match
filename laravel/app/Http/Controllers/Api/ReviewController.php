<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Models\Swap;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ReviewController extends Controller
{
    /**
     * Get all reviews for a specific user with rating statistics.
     *
     * @param int $userId
     * @return \Illuminate\Http\JsonResponse
     */
    public function getUserReviews($userId)
    {
        // Get reviews with pagination
        $reviews = Review::where('reviewed_user_id', $userId)
            ->with([
                'reviewer:id,name,profile_picture_url',
                'swap.itemA:id,name,user_id',
                'swap.itemB:id,name,user_id',
                'swap.itemA.images',
                'swap.itemB.images'
            ])
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        // Calculate rating statistics
        $stats = $this->calculateRatingStats($userId);

        return response()->json([
            'reviews' => $reviews->items(),
            'stats' => $stats,
            'pagination' => [
                'current_page' => $reviews->currentPage(),
                'last_page' => $reviews->lastPage(),
                'per_page' => $reviews->perPage(),
                'total' => $reviews->total(),
            ]
        ]);
    }

    /**
     * Create a new review.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'swap_id' => 'required|integer|exists:swaps,id',
            'reviewed_user_id' => 'required|integer|exists:users,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
            'photos' => 'nullable|array',
            'photos.*' => 'nullable|url',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = Auth::user();

        // Verify the swap exists and has status 'trade_complete'
        $swap = Swap::find($request->swap_id);
        
        if (!$swap) {
            return response()->json(['error' => 'Swap not found'], 404);
        }

        if ($swap->status !== 'trade_complete') {
            return response()->json([
                'error' => 'Reviews can only be created for completed trades'
            ], 422);
        }

        // Verify the authenticated user is part of this swap
        $userItemId = $swap->itemA->user_id === $user->id ? $swap->item_a_id : 
                      ($swap->itemB->user_id === $user->id ? $swap->item_b_id : null);

        if (!$userItemId) {
            return response()->json([
                'error' => 'You are not authorized to review this trade'
            ], 403);
        }

        // Verify the reviewed user is the other participant
        $otherUserId = $swap->itemA->user_id === $user->id ? $swap->itemB->user_id : $swap->itemA->user_id;
        
        if ($request->reviewed_user_id != $otherUserId) {
            return response()->json([
                'error' => 'You can only review the other participant in this trade'
            ], 422);
        }

        // Check for duplicate review (unique constraint will also catch this)
        $existingReview = Review::where('swap_id', $request->swap_id)
            ->where('reviewer_user_id', $user->id)
            ->first();

        if ($existingReview) {
            return response()->json([
                'error' => 'You have already reviewed this trade'
            ], 422);
        }

        // Create the review
        $review = Review::create([
            'swap_id' => $request->swap_id,
            'reviewer_user_id' => $user->id,
            'reviewed_user_id' => $request->reviewed_user_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
            'photos' => $request->photos,
        ]);

        // Load relationships for response
        $review->load([
            'reviewer:id,name,profile_picture_url',
            'swap.itemA:id,name',
            'swap.itemB:id,name'
        ]);

        return response()->json([
            'message' => 'Review created successfully',
            'review' => $review
        ], 201);
    }

    /**
     * Get a single review.
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $review = Review::with([
            'reviewer:id,name,profile_picture_url',
            'reviewedUser:id,name',
            'swap.itemA:id,name',
            'swap.itemB:id,name'
        ])->find($id);

        if (!$review) {
            return response()->json(['error' => 'Review not found'], 404);
        }

        return response()->json(['review' => $review]);
    }

    /**
     * Calculate rating statistics for a user.
     *
     * @param int $userId
     * @return array
     */
    private function calculateRatingStats($userId)
    {
        $reviews = Review::where('reviewed_user_id', $userId)->get();
        $totalReviews = $reviews->count();

        if ($totalReviews === 0) {
            return [
                'average_rating' => 0,
                'total_reviews' => 0,
                'rating_distribution' => [
                    '5' => 0,
                    '4' => 0,
                    '3' => 0,
                    '2' => 0,
                    '1' => 0,
                ]
            ];
        }

        $averageRating = round($reviews->avg('rating'), 2);

        return [
            'average_rating' => $averageRating,
            'total_reviews' => $totalReviews,
            'rating_distribution' => [
                '5' => $reviews->where('rating', 5)->count(),
                '4' => $reviews->where('rating', 4)->count(),
                '3' => $reviews->where('rating', 3)->count(),
                '2' => $reviews->where('rating', 2)->count(),
                '1' => $reviews->where('rating', 1)->count(),
            ]
        ];
    }
}
