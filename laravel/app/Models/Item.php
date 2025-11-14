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
            'category_id',
            'title',
            'description',
            'condition',
            'estimated_value',
            'currency',
            'location_city',
            'location_lat',
            'location_lon',
            'wants_description',
            'status',
        ];
    
        /**
         * Get the user that owns the item.
         */
        public function user(): BelongsTo
        {
            return $this->belongsTo(User::class);
        }
    
        /**
         * Get the category of the item.
         */
        public function category()
        {
            return $this->belongsTo(Category::class);
        }
    
        /**
         * Get the images for the item.
         */
        public function images()
        {
            return $this->hasMany(ItemImage::class);
        }
    
        /**
         * Get the desired categories for the item.
         */
        public function wants()
        {
            return $this->hasMany(ItemWant::class);
        }
    
        /**
         * Get all swipes on this item.
         */
        public function swipesOnThisItem()
        {
            return $this->hasMany(Swipe::class, 'swiped_on_item_id');
        }
    
        /**
         * Get all swipes made with this item.
         */
        public function swipesWithThisItem()
        {
            return $this->hasMany(Swipe::class, 'swiper_item_id');
        }
    
        /**
         * Get all matches where this item is item A.
         */
        public function matchesAsItemA()
        {
            return $this->hasMany(BarterMatch::class, 'item_a_id');
        }
    
        /**
         * Get all matches where this item is item B.
         */
        public function matchesAsItemB()
        {
            return $this->hasMany(BarterMatch::class, 'item_b_id');
        }
    
        /**
         * Get all matches for this item.
         */
        public function matches()
        {
            return $this->matchesAsItemA()->union($this->matchesAsItemB()->toBase());
        }
    }
    