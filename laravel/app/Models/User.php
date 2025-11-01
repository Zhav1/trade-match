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
        'password',
        'fcm_token',
        'lat',
        'lng',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Get all likes given by the user.
     */
    public function likes(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Like::class);
    }

    /**
     * Get all matches where user is participant A
     */
    public function matchesAsUserA(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(BarterMatch::class, 'user_a_id');
    }

    /**
     * Get all matches where user is participant B
     */
    public function matchesAsUserB(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(BarterMatch::class, 'user_b_id');
    }

    /**
     * Get all matches for the user (both as A and B)
     */
    public function matches()
    {
        return $this->matchesAsUserA()->orWhere('user_b_id', $this->id);
    }

        /**
         * Get all messages sent by the user.
         */
        public function messages(): \Illuminate\Database\Eloquent\Relations\HasMany
        {
            return $this->hasMany(Message::class)->orderBy('created_at', 'desc');
        }
}
