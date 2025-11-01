<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response;
use App\Models\BarterMatch;

class ChatController extends Controller
{
    /**
     * Get message history for a match (authorized participants only).
     */
    public function getMessages(Request $request, BarterMatch $match)
    {
        $user = $request->user();

        // Authorization: ensure user is participant A or B
        if ($user->id !== $match->user_a_id && $user->id !== $match->user_b_id) {
            return response()->json(['message' => 'Forbidden'], Response::HTTP_FORBIDDEN);
        }

        $messages = $match->messages()->with('user:id,name')->orderBy('created_at', 'asc')->get();

        return response()->json($messages);
    }

    /**
     * Send a new message in a match chat.
     */
    public function sendMessage(Request $request, BarterMatch $match)
    {
        $user = $request->user();

        // Authorization
        if ($user->id !== $match->user_a_id && $user->id !== $match->user_b_id) {
            return response()->json(['message' => 'Forbidden'], Response::HTTP_FORBIDDEN);
        }

        $validated = $request->validate([
            'content' => 'required|string|max:2000',
        ]);

        $message = $match->messages()->create([
            'user_id' => $user->id,
            'content' => $validated['content'],
        ]);

        $message->load('user:id,name');

        // TODO: Add real-time event dispatch here (e.g., NewChatMessage::dispatch($message))

        return response()->json($message);
    }
}
