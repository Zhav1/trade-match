<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response;
use App\Models\BarterMatch;
use App\Models\Message;

class ChatController extends Controller
{
    /**
     * Get message history for a match (authorized participants only).
     */
    public function getMessages(Request $request, BarterMatch $match)
    {
        $this->authorize('view', $match);

        $messages = $match->messages()->with('sender:id,name')->orderBy('created_at', 'asc')->get();

        return response()->json($messages);
    }

    /**
     * Send a new message in a match chat.
     */
    public function sendMessage(Request $request, BarterMatch $match)
    {
        $this->authorize('update', $match);

        $validated = $request->validate([
            'message_text' => 'required|string|max:2000',
        ]);

        $message = $match->messages()->create([
            'sender_user_id' => $request->user()->id,
            'message_text' => $validated['message_text'],
        ]);

        $message->load('sender:id,name');

        // TODO: Add real-time event dispatch here (e.g., NewChatMessage::dispatch($message))

        return response()->json($message);
    }
}
