<?php

namespace App\Jobs;

use App\Models\Item;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Cache;

class WarmExploreCacheJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        // Cache all active items with their relationships
        $items = Item::where('status', 'active')
            ->with(['user', 'category', 'images', 'wants.category'])
            ->orderBy('created_at', 'desc')
            ->get();

        // Store in Redis for 1 hour (or until next update)
        Cache::put('explore:active_items', $items, 3600);
    }
}
