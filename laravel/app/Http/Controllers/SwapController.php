<?php

namespace App\Http\Controllers;

use App\Models\Message;
use App\Models\Swap;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Http\Resources\SwapResource;
use App\Http\Requests\SendMessageRequest;
use App\Http\Requests\SuggestLocationRequest;

class SwapController extends Controller
{
    /**
     * Get the list of swaps for the authenticated user.
     * Supports optional ?status query parameter for filtering.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $query = Swap::where(function ($q) use ($user) {
                $q->whereHas('itemA', fn($q2) => $q2->where('user_id', $user->id))
                  ->orWhereHas('itemB', fn($q2) => $q2->where('user_id', $user->id));
            });
        
        // Optional status filtering
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }
        
        $swaps = $query->with([
                'itemA.images', 
                'itemB.images', 
                'itemA.user', 
                'itemB.user',
                'latestMessage' => fn($q) => $q->latest()->limit(1),
            ])
            ->orderBy('updated_at', 'desc')
            ->get();

        return SwapResource::collection($swaps);
    }

    /**
     * Get message history for a swap.
     */
    public function getMessages(Request $request, Swap $swap): JsonResponse
    {
        $this->authorize('view', $swap);

        $messages = $swap->messages()->with('sender:id,name')->orderBy('created_at', 'asc')->get();

        return response()->json($messages);
    }

    /**
     * Send a new message in a swap chat.
     * Uses SendMessageRequest for validation (MASTER_ARCHITECTURE.md Issue #5)
     */
    public function sendMessage(SendMessageRequest $request, Swap $swap): JsonResponse
    {
        $this->authorize('update', $swap);

        // Validation already handled by SendMessageRequest
        $validated = $request->validated();

        $message = $swap->messages()->create([
            'sender_user_id' => $request->user()->id,
            'message_text' => $validated['message_text'],
            'type' => 'text',
        ]);

        $message->load('sender:id,name');

        broadcast(new \App\Events\NewChatMessage($message))->toOthers();

        // Create notification for the recipient
        $recipientUserId = $swap->itemA->user_id === $request->user()->id 
            ? $swap->itemB->user_id 
            : $swap->itemA->user_id;
        
        app(\App\Services\NotificationService::class)->createMessageNotification(
            $recipientUserId,
            $swap->id,
            $request->user()->name
        );

        return response()->json($message);
    }

    /**
     * Confirm a trade for a swap from the user's side.
     */
    public function confirmTrade(Request $request, Swap $swap): JsonResponse
    {
        $this->authorize('update', $swap);

        $user = $request->user();
        
        if ($swap->itemA->user_id === $user->id) {
            $swap->item_a_owner_confirmed = true;
        } elseif ($swap->itemB->user_id === $user->id) {
            $swap->item_b_owner_confirmed = true;
        } else {
            return response()->json(['message' => 'You are not authorized to confirm this trade.'], 403);
        }

        // If both parties have confirmed, finalize the trade
        if ($swap->item_a_owner_confirmed && $swap->item_b_owner_confirmed) {
            $swap->status = 'trade_complete';
            $swap->itemA->update(['status' => 'traded']);
            $swap->itemB->update(['status' => 'traded']);
        }

        $swap->save();

        return response()->json([
            'message' => 'Trade confirmation updated successfully.',
            'swap' => $swap->load(['itemA', 'itemB']),
        ]);
    }

    /**
     * Suggest a location for the trade.
     * Uses SuggestLocationRequest for validation (MASTER_ARCHITECTURE.md Issue #5)
     */
    public function suggestLocation(SuggestLocationRequest $request, Swap $swap): JsonResponse
    {
        $this->authorize('update', $swap);
        
        // Validation already handled by SuggestLocationRequest
        $validated = $request->validated();

        $user = $request->user();
        $isUserA = $swap->itemA->user_id === $user->id;

        $message = $swap->messages()->create([
            'sender_user_id' => $user->id,
            'message_text' => 'Suggested a location: ' . $validated['location_name'],
            'type' => 'location',
            'lat' => $validated['lat'],
            'lng' => $validated['lng'],
            'location_name' => $validated['location_name'],
            'location_address' => $validated['location_address'],
            'location_agreed_by_user_a' => $isUserA,
            'location_agreed_by_user_b' => !$isUserA,
        ]);

        // SECURITY FIX: Set timeout tracking timestamp (MASTER_ARCHITECTURE.md Issue #4)
        $swap->update([
            'status' => 'location_suggested',
            'location_suggested_at' => now()
        ]);

        $message->load('sender:id,name');
        broadcast(new \App\Events\NewChatMessage($message))->toOthers();

        return response()->json($message);
    }

    /**
     * Accept a location for the trade.
     */
    public function acceptLocation(Request $request, Swap $swap): JsonResponse
    {
        $this->authorize('update', $swap);
        
        $validated = $request->validate([
            'message_id' => 'required|exists:messages,id',
        ]);

        $message = Message::find($validated['message_id']);

        if ($message->swap_id !== $swap->id) {
            return response()->json(['message' => 'Message does not belong to this swap.'], 403);
        }

        $user = $request->user();
        $isUserA = $swap->itemA->user_id === $user->id;

        if ($isUserA) {
            $message->location_agreed_by_user_a = true;
        } else {
            $message->location_agreed_by_user_b = true;
        }
        $message->save();

        if ($message->location_agreed_by_user_a && $message->location_agreed_by_user_b) {
            $swap->update(['status' => 'location_agreed']);
            
            // Create a system message or notification
            $systemMessage = $swap->messages()->create([
                'sender_user_id' => $user->id, // Or system ID
                'message_text' => 'Location agreed: ' . $message->location_name,
                'type' => 'location_agreement',
            ]);
            
            $systemMessage->load('sender:id,name');
            broadcast(new \App\Events\NewChatMessage($systemMessage))->toOthers();
        }

        return response()->json(['message' => 'Location accepted', 'data' => $message]);
    }
}
