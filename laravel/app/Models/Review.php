<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'swap_id',
        'reviewer_user_id',
        'reviewed_user_id',
        'rating',
        'comment',
        'photos',
    ];

    /**
     * The attributes that should be cast.
     */
    protected function casts(): array
    {
        return [
            'photos' => 'array',
            'rating' => 'integer',
        ];
    }

    /**
     * Get the swap that this review belongs to.
     */
    public function swap()
    {
        return $this->belongsTo(Swap::class);
    }

    /**
     * Get the user who wrote this review.
     */
    public function reviewer()
    {
        return $this->belongsTo(User::class, 'reviewer_user_id');
    }

    /**
     * Get the user who is being reviewed.
     */
    public function reviewedUser()
    {
        return $this->belongsTo(User::class, 'reviewed_user_id');
    }
}
