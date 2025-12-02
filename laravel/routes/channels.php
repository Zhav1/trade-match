<?php

use Illuminate\Support\Facades\Broadcast;
use App\Models\User;
use App\Models\Swap;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('swap.{swapId}', function (User $user, int $swapId) {
    $swap = Swap::find($swapId);
    if (!$swap) return false;
    
    // Check if user is part of the swap (itemA or itemB owner)
    // We need to load items to check ownership if not loaded
    if (!$swap->relationLoaded('itemA')) $swap->load('itemA');
    if (!$swap->relationLoaded('itemB')) $swap->load('itemB');
    
    return $swap->itemA->user_id === $user->id || $swap->itemB->user_id === $user->id;
});
