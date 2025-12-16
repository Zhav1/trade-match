<?php

namespace App\Jobs;

use App\Models\Item;
use App\Models\Swipe;
use App\Models\Swap;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessSwipeJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $swipe;

    /**
     * Create a new job instance.
     *
     * @param \App\Models\Swipe $swipe
     */
    public function __construct(Swipe $swipe)
    {
        $this->swipe = $swipe;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        // 1. Ensure the action was a 'like'
        if ($this->swipe->action !== 'like') {
            return;
        }

        // 2. Check for a mutual like (a reciprocal swipe)
        $reciprocalSwipeExists = Swipe::where('swiper_item_id', $this->swipe->swiped_on_item_id)
            ->where('swiped_on_item_id', $this->swipe->swiper_item_id)
            ->where('action', 'like')
            ->exists();

        // 3. If no mutual like, do nothing
        if (! $reciprocalSwipeExists) {
            return;
        }

        // 4. A swap is found! Get the items.
        $itemA = Item::find($this->swipe->swiper_item_id);
        $itemB = Item::find($this->swipe->swiped_on_item_id);

        if (!$itemA || !$itemB) {
            Log::warning('Could not find one or both items for a swap.', ['item_a' => $this->swipe->swiper_item_id, 'item_b' => $this->swipe->swiped_on_item_id]);
            return;
        }
        
        // 5. Create the swap record.
        // Ensure consistent ordering of item_a and item_b to prevent duplicates.
        $item1_id = min($itemA->id, $itemB->id);
        $item2_id = max($itemA->id, $itemB->id);

        $swap = Swap::firstOrCreate(
            [
                'item_a_id' => $item1_id,
                'item_b_id' => $item2_id,
            ],
            [
                'status' => 'active' // as per GEMINI.md
            ]
        );

        // 6. Dispatch notifications if the swap was just created.
        if ($swap->wasRecentlyCreated) {
            // Reload the items to get the user relationship
            $itemA->load('user');
            $itemB->load('user');

            if ($itemA->user && $itemB->user) {
                // Create notifications for both users using NotificationService
                $notificationService = app(\App\Services\NotificationService::class);
                
                $notificationService->createSwapNotification(
                    $itemA->user->id,
                    $swap->id,
                    $itemB->user->name
                );
                
                $notificationService->createSwapNotification(
                    $itemB->user->id,
                    $swap->id,
                    $itemA->user->name
                );
            } else {
                Log::error('Could not dispatch notification because user was missing.', ['swap_id' => $swap->id]);
            }
        }
    }
}
