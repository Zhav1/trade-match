<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SwapResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     * Sanitizes item and user data to prevent information disclosure.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'item_a_id' => $this->item_a_id,
            'item_b_id' => $this->item_b_id,
            'status' => $this->status,
            'item_a_owner_confirmed' => $this->item_a_owner_confirmed,
            'item_b_owner_confirmed' => $this->item_b_owner_confirmed,
            'location_suggested_at' => $this->location_suggested_at ?? null,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            
            // SECURITY: Use ItemResource to filter sensitive data
            'itemA' => new ItemResource($this->whenLoaded('itemA')),
            'itemB' => new ItemResource($this->whenLoaded('itemB')),
            
            // Latest message (if loaded)
            'latestMessage' => $this->whenLoaded('latestMessage'),
        ];
    }
}
