<?php

namespace App\Console\Commands;

use App\Models\Swap;
use Illuminate\Console\Command;

class ResetExpiredLocationSuggestions extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'swaps:reset-expired-locations';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Reset location suggestions that have been pending for more than 48 hours';

    /**
     * Execute the console command.
     * SECURITY FIX: Prevents location agreement deadlock (MASTER_ARCHITECTURE.md Issue #4)
     */
    public function handle(): void
    {
        $resetCount = Swap::where('status', 'location_suggested')
            ->where('location_suggested_at', '<', now()->subHours(48))
            ->update([
                'status' => 'active',
                'location_suggested_at' => null
            ]);

        $this->info("Reset {$resetCount} expired location suggestions.");
    }
}
