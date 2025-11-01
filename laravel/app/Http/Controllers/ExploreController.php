<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redis;
use App\Models\Item;
use App\Models\Like;

class ExploreController extends Controller
{
    /**
     * Return the explore feed for the authenticated user.
     */
    public function getFeed(Request $request)
    {
        $user = $request->user();
        $cacheKey = "feed:user:{$user->id}";

        // Check cache
        if ($cachedFeed = Redis::get($cacheKey)) {
            return response()->json(json_decode($cachedFeed));
        }

        // Items the user has already swiped on
        $swipedItemIds = Like::where('user_id', $user->id)->pluck('item_id');

        // Query database for feed items
        $feedItems = Item::where('status', 'active')
            ->where('user_id', '!=', $user->id)
            ->whereNotIn('id', $swipedItemIds)
            ->with('user')
            ->inRandomOrder()
            ->limit(50)
            ->get();

        // Store in Redis (cache-aside)
        Redis::set($cacheKey, $feedItems->toJson(), 'EX', 3600);

        return response()->json($feedItems);
    }
}
