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

        // 1. Get items from Redis Cache
        $cachedItems = \Illuminate\Support\Facades\Cache::get('explore:active_items');

        // If cache is empty, trigger the job synchronously to warm it up
        if (!$cachedItems) {
            \App\Jobs\WarmExploreCacheJob::dispatchSync();
            $cachedItems = \Illuminate\Support\Facades\Cache::get('explore:active_items', collect());
        }

        // 2. Get IDs of items the user has already swiped on
        // Optimization: This could also be cached per user, but for now DB is okay for this specific query
        $swipedItemIds = Swipe::where('swiper_user_id', $user->id)->pluck('swiped_on_item_id')->toArray();

        // 3. Filter the cached list in memory
        // - Exclude user's own items
        // - Exclude items already swiped
        $feedItems = $cachedItems->filter(function ($item) use ($user, $swipedItemIds) {
            return $item->user_id !== $user->id && !in_array($item->id, $swipedItemIds);
        })->values();

        // 4. Apply simple randomization or sorting if needed (e.g. shuffle)
        $feedItems = $feedItems->shuffle()->take(50);

        return response()->json($feedItems);
    }
}
