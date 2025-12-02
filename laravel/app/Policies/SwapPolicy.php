<?php

namespace App\Policies;

use App\Models\Swap;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class SwapPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Swap $swap): bool
    {
        return $user->id === $swap->itemA->user_id || $user->id === $swap->itemB->user_id;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Swap $swap): bool
    {
        return $user->id === $swap->itemA->user_id || $user->id === $swap->itemB->user_id;
    }
}
