<?php

namespace App\Jobs;

use App\Models\User;
use App\Models\BarterMatch;
use Illuminate\Support\Facades\Log;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendMatchNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public User $user;
    public BarterMatch $match;

    /**
     * Create a new job instance.
     */
    public function __construct(User $user, BarterMatch $match)
    {
        $this->user = $user;
        $this->match = $match;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        // If user has no FCM token, skip
        if (! $this->user->fcm_token) {
            return;
        }

        $title = 'New Match!';
        $body = 'You have a new match. Start chatting now!';

        // Simulate sending FCM — replace with real FCM service in production
        Log::info("Sending FCM notification to user {$this->user->id}", [
            'fcm_token' => $this->user->fcm_token,
            'title' => $title,
            'body' => $body,
            'match_id' => $this->match->id,
        ]);

        // TODO: Implement actual FCM service call here
        // FcmService::send($this->user->fcm_token, $title, $body, ['match_id' => $this->match->id]);
    }
}
