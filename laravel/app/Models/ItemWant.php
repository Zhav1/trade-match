<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ItemWant extends Model
{
    use HasFactory;

    protected $fillable = [
        'item_id',
        'wanted_category_id',
    ];

    public function item()
    {
        return $this->belongsTo(Item::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class, 'wanted_category_id');
    }
}
