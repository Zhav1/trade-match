<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Item;
use App\Models\Swipe;
use App\Models\BarterMatch;

class SwipeController extends Controller
{
    /**
     * Store a new swipe and check for a match.
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
        $action = $validated['action'];

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

        // Create the swipe
        $swipe = Swipe::create([
            'swiper_user_id' => $user->id,
            'swiper_item_id' => $swiperItemId,
            'swiped_on_item_id' => $swipedOnItemId,
            'action' => $action,
        ]);

        if ($action === 'like') {
            // Check for a mutual like (a match)
            $mutualLike = Swipe::where('swiper_user_id', $swipedOnItem->user_id)
                ->where('swiper_item_id', $swipedOnItemId)
                ->where('swiped_on_item_id', $swiperItemId)
                ->where('action', 'like')
                ->exists();

            if ($mutualLike) {
                // A match is found!
                $match = BarterMatch::create([
                    'item_a_id' => $swiperItemId,
                    'item_b_id' => $swipedOnItemId,
                    'status' => 'matched',
                ]);
                // TODO: Dispatch a notification to both users
                return response()->json(['message' => 'Match found!', 'match' => $match], 200);
            }
        }

        return response()->json(['message' => 'Swipe recorded'], 200);
    }
}
