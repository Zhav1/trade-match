<?php

namespace App\Jobs;

use App\Models\User;
use App\Models\Swap;
use Illuminate\Support\Facades\Log;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendSwapNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public User $user;
    public Swap $swap;

    /**
     * Create a new job instance.
     */
    public function __construct(User $user, Swap $swap)
    {
        $this->user = $user;
        $this->swap = $swap;
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

        $title = 'New Swap!';
        $body = 'You have a new swap. Start chatting now!';

        // Simulate sending FCM — replace with real FCM service in production
        Log::info("Sending FCM notification to user {$this->user->id}", [
            'fcm_token' => $this->user->fcm_token,
            'title' => $title,
            'body' => $body,
            'swap_id' => $this->swap->id,
        ]);

        // TODO: Implement actual FCM service call here
        // FcmService::send($this->user->fcm_token, $title, $body, ['swap_id' => $this->swap->id]);
    }
}
