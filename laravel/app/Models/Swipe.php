<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Swipe extends Model
{
    use HasFactory;

    protected $fillable = [
        'swiper_user_id',
        'swiper_item_id',
        'swiped_on_item_id',
        'action',
    ];

    public function swiperUser()
    {
        return $this->belongsTo(User::class, 'swiper_user_id');
    }

    public function swiperItem()
    {
        return $this->belongsTo(Item::class, 'swiper_item_id');
    }

    public function swipedOnItem()
    {
        return $this->belongsTo(Item::class, 'swiped_on_item_id');
    }
}
