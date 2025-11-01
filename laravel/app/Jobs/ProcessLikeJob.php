<?php

namespace App\Jobs;

use App\Models\Item;
use App\Models\User;
use App\Models\Like;
use App\Models\BarterMatch;
use App\Jobs\SendMatchNotificationJob;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class ProcessLikeJob implements ShouldQueue
{
	use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

	public User $user;
	public Item $item;

	/**
	 * Create a new job instance.
	 */
	public function __construct(User $user, Item $item)
	{
		$this->user = $user;
		$this->item = $item;
	}

	/**
	 * Execute the job.
	 */
	public function handle(): void
	{
		// Get the owner of the liked item
		$itemOwner = $this->item->user;

		if (! $itemOwner) {
			return;
		}

		// Get active item ids belonging to the user who performed the like
		$userItemIds = Item::where('user_id', $this->user->id)
			->where('status', 'active')
			->pluck('id');

		if ($userItemIds->isEmpty()) {
			return;
		}

		// Check if the owner of the liked item has liked any of the user's active items
		$mutualLike = Like::where('user_id', $itemOwner->id)
			->whereIn('item_id', $userItemIds)
			->first();

		if (! $mutualLike) {
			// No reciprocal like found
			return;
		}

		// The specific item of the user that was liked by the item owner
		$userItem = $mutualLike->item;

		if (! $userItem) {
			return;
		}

		// Create the match (avoid duplicates)
		$match = BarterMatch::firstOrCreate([
			'user_a_id' => $this->user->id,
			'user_b_id' => $itemOwner->id,
			'item_a_id' => $this->item->id,
			'item_b_id' => $userItem->id,
		], ['status' => 'active']);

		// Dispatch notifications to both participants
		SendMatchNotificationJob::dispatch($this->user, $match);
		SendMatchNotificationJob::dispatch($itemOwner, $match);
	}
}
