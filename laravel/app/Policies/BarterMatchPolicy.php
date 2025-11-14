<?php

namespace App\Policies;

use App\Models\BarterMatch;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class BarterMatchPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, BarterMatch $match): bool
    {
        return $user->id === $match->itemA->user_id || $user->id === $match->itemB->user_id;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, BarterMatch $match): bool
    {
        return $user->id === $match->itemA->user_id || $user->id === $match->itemB->user_id;
    }
}
