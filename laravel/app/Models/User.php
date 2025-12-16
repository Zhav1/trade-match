<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'google_id',
        'phone',
        'password',
        'profile_picture_url',
        'default_location_city',
        'default_lat',
        'default_lon',
        'rating',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected function casts(): array
    {
        return [
            'password' => 'hashed',
        ];
    }

    /**
     * Get the items for the user.
     */
    public function items()
    {
        return $this->hasMany(Item::class);
    }

    /**
     * Get all swipes made by the user.
     */
    public function swipes()
    {
        return $this->hasMany(Swipe::class, 'swiper_user_id');
    }

    /**
     * Get all messages sent by the user.
     */
    public function messages()
    {
        return $this->hasMany(Message::class, 'sender_user_id');
    }

    /**
     * Get all reviews received by the user.
     */
    public function reviewsReceived()
    {
        return $this->hasMany(Review::class, 'reviewed_user_id');
    }

    /**
     * Get all reviews given by the user.
     */
    public function reviewsGiven()
    {
        return $this->hasMany(Review::class, 'reviewer_user_id');
    }
}
