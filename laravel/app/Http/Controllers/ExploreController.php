<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Item;
use App\Models\Swipe;

class ExploreController extends Controller
{
    /**
     * Return the explore feed for the authenticated user.
     */
    public function getFeed(Request $request)
    {
        $user = $request->user();

        // Items the user has already swiped on
        $swipedItemIds = Swipe::where('swiper_user_id', $user->id)->pluck('swiped_on_item_id');

        // Query database for feed items
        $feedItems = Item::where('status', 'active')
            ->where('user_id', '!=', $user->id)
            ->whereNotIn('id', $swipedItemIds)
            ->with(['user', 'category', 'images', 'wants.category'])
            ->inRandomOrder()
            ->limit(50)
            ->get();

        return response()->json($feedItems);
    }
}
