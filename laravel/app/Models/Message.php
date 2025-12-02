<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Message extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<string>
     */
        protected $fillable = [
            'swap_id',
            'sender_user_id',
            'message_text',
        ];
    
        /**
         * Get the swap that this message belongs to.
         */
        public function swap(): BelongsTo
        {
            return $this->belongsTo(Swap::class, 'swap_id');
        }
    
        /**
         * Get the user who sent this message.
         */
        public function sender(): BelongsTo
        {
            return $this->belongsTo(User::class, 'sender_user_id');
        }
    }
    