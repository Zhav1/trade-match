<?php

namespace App\Http\Controllers;

use App\Models\BarterMatch;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class TradeController extends Controller
{
    /**
     * Confirm a trade between two users.
     *
     * @param Request $request
     * @param BarterMatch $match
     * @return JsonResponse
     */
    public function confirmTrade(Request $request, BarterMatch $match): JsonResponse
    {
        $user = $request->user();

        // Check if user is part of the match
        if ($match->user_a_id !== $user->id && $match->user_b_id !== $user->id) {
            return response()->json(['message' => 'You are not authorized to confirm this trade'], 403);
        }

        // Determine user roles
        $currentUserRole = ($match->user_a_id === $user->id) ? 'a' : 'b';
        $otherUserRole = ($currentUserRole === 'a') ? 'b' : 'a';

        // Check if this is the second confirmation
        if ($match->status === "{$otherUserRole}_confirmed") {
            $match->status = 'exchanged';
            $match->item_a->update(['status' => 'exchanged']);
            $match->item_b->update(['status' => 'exchanged']);
        }
        // Check if this is the first confirmation
        elseif ($match->status === 'active') {
            $match->status = "{$currentUserRole}_confirmed";
        } else {
            return response()->json(['message' => 'Invalid match status for confirmation'], 400);
        }

        $match->save();

        return response()->json([
            'message' => 'Trade confirmation updated successfully',
            'match' => $match->load(['item_a', 'item_b'])
        ]);
    }
}