<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Item;
use App\Models\Swipe;
use App\Jobs\ProcessSwipeJob;
use App\Models\BarterMatch;

class SwipeController extends Controller
{
    /**
     * Store a new swipe and dispatch a job to check for a match.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'swiper_item_id' => 'required|exists:items,id',
            'swiped_on_item_id' => 'required|exists:items,id',
            'action' => 'required|in:like,dislike',
        ]);

        $user = $request->user();
        $swiperItemId = $validated['swiper_item_id'];
        $swipedOnItemId = $validated['swiped_on_item_id'];

        // Ensure the user owns the item they are swiping with
        $swiperItem = Item::find($swiperItemId);
        if ($swiperItem->user_id !== $user->id) {
            return response()->json(['message' => 'You do not own the item you are swiping with.'], 403);
        }

        // Prevent swiping on own item
        $swipedOnItem = Item::find($swipedOnItemId);
        if ($swipedOnItem->user_id === $user->id) {
            return response()->json(['message' => 'Cannot swipe on your own item'], 403);
        }

        // Create the swipe record
        $swipe = Swipe::create([
            'swiper_user_id' => $user->id, // Assuming this column exists
            'swiper_item_id' => $swiperItemId,
            'swiped_on_item_id' => $swipedOnItemId,
            'action' => $validated['action'],
        ]);

        // If it was a 'like', dispatch the job to process the match asynchronously
        if ($swipe->action === 'like') {
            ProcessSwipeJob::dispatch($swipe);
        }

        // Immediately return a response
        return response()->json(['message' => 'Swipe recorded'], 200);
    }
}
