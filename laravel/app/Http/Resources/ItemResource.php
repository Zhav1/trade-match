<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ItemResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     * Applies fuzzy location (3 decimals = ~100m precision) and filters user data.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'category_id' => $this->category_id,
            'title' => $this->title,
            'description' => $this->description,
            'condition' => $this->condition,
            'estimated_value' => $this->estimated_value,
            'currency' => $this->currency,
            'location_city' => $this->location_city,
            // SECURITY: Fuzzy location (3 decimals = ~100m precision)
            // Prevents exact GPS tracking (MASTER_ARCHITECTURE.md Issue #2)
            'location_lat' => $this->location_lat ? round($this->location_lat, 3) : null,
            'location_lon' => $this->location_lon ? round($this->location_lon, 3) : null,
            'wants_description' => $this->wants_description,
            'status' => $this->status,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            
            // Relationships - only loaded if requested
            'user' => new UserPublicResource($this->whenLoaded('user')),
            'category' => $this->whenLoaded('category'),
            'images' => $this->whenLoaded('images'),
            'wants' => $this->whenLoaded('wants'),
        ];
    }
}
