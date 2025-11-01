<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Item;
use App\Models\Like;
use App\Jobs\ProcessLikeJob;

class LikeController extends Controller
{
    /**
     * Store a new like and dispatch background matching job.
     */
    public function store(Request $request, Item $item)
    {
        $user = $request->user();

        // Prevent liking own item
        if ($item->user_id === $user->id) {
            return response()->json(['message' => 'Cannot like your own item'], 403);
        }

        // Prevent duplicate likes
        $existingLike = Like::where('user_id', $user->id)
            ->where('item_id', $item->id)
            ->exists();

        if ($existingLike) {
            return response()->json(['message' => 'Already liked'], 200);
        }

        // Create like
        Like::create([
            'user_id' => $user->id,
            'item_id' => $item->id,
        ]);

        // Dispatch matching job (async)
        ProcessLikeJob::dispatch($user, $item);

        return response()->json(['message' => 'Like recorded'], 200);
    }
}
