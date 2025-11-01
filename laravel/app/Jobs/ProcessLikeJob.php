<?php

namespace App\Jobs;

use App\Models\Item;
use App\Models\User;
use App\Models\Like;
use App\Models\BarterMatch;
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
		// Basic matching logic placeholder:
		// Look for reciprocal like where owner of $this->item liked one of $this->user's items
		$owner = $this->item->user;

		// Find likes where owner liked any item belonging to the liker
		$mutual = Like::where('user_id', $owner->id)
			->whereIn('item_id', function ($query) {
				$query->select('id')->from('items')->where('user_id', $this->user->id);
			})
			->first();

		if ($mutual) {
			// Create match record. For safety, ensure no duplicate match exists.
			BarterMatch::firstOrCreate([
				'user_a_id' => $this->user->id,
				'user_b_id' => $owner->id,
				'item_a_id' => $this->item->id,
				'item_b_id' => $mutual->item_id,
			], ['status' => 'active']);
		}
	}
}
