<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Item extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<string>
     */
    protected $fillable = [
        'user_id',
        'title',
        'description',
        'status',
        'lat',
        'lng',
        'cover_image_path',
    ];

    /**
     * Get the user that owns the item.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get all likes received by this item.
     */
    public function likes(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Like::class);
    }

    /**
     * Get all matches where this item is item A
     */
    public function matchesAsItemA(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(BarterMatch::class, 'item_a_id');
    }

    /**
     * Get all matches where this item is item B
     */
    public function matchesAsItemB(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(BarterMatch::class, 'item_b_id');
    }

    /**
     * Get all matches for this item (both as A and B)
     */
    public function matches()
    {
        return $this->matchesAsItemA()->orWhere('item_b_id', $this->id);
    }
}