<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Swap extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'swaps';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<string>
     */
    protected $fillable = [
        'user_a_id',
        'user_b_id',
        'item_a_id',
        'item_b_id',
        'status',
        'item_a_owner_confirmed',
        'item_b_owner_confirmed',
    ];

    /**
     * Get the first item in the swap.
     */
    public function itemA(): BelongsTo
    {
        return $this->belongsTo(Item::class, 'item_a_id');
    }

    /**
     * Get the second item in the swap.
     */
    public function itemB(): BelongsTo
    {
        return $this->belongsTo(Item::class, 'item_b_id');
    }

    /**
     * Get the user for the first item.
     */
    public function userA(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_a_id');
    }

    /**
     * Get the user for the second item.
     */
    public function userB(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_b_id');
    }

    /**
     * Get all messages in this swap's chat.
     */
    public function messages(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Message::class, 'swap_id')->orderBy('created_at');
    }
}
