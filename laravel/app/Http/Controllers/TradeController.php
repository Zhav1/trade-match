<?php

namespace App\Http\Controllers;

use App\Models\BarterMatch;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class TradeController extends Controller
{
    /**
     * Confirm a trade for a match.
     */
    public function confirmTrade(Request $request, BarterMatch $match): JsonResponse
    {
        $this->authorize('update', $match);

        $user = $request->user();
        $isItemAOwner = $match->itemA->user_id === $user->id;
        $isItemBOwner = $match->itemB->user_id === $user->id;

        if (!$isItemAOwner && !$isItemBOwner) {
            return response()->json(['message' => 'You are not authorized to confirm this trade.'], 403);
        }

        if ($isItemAOwner) {
            $match->item_a_owner_confirmed = true;
        }

        if ($isItemBOwner) {
            $match->item_b_owner_confirmed = true;
        }

        if ($match->item_a_owner_confirmed && $match->item_b_owner_confirmed) {
            $match->status = 'trade_complete';
            $match->itemA->update(['status' => 'traded']);
            $match->itemB->update(['status' => 'traded']);
        }

        $match->save();

        return response()->json([
            'message' => 'Trade confirmation updated successfully.',
            'match' => $match->load(['itemA', 'itemB']),
        ]);
    }
}