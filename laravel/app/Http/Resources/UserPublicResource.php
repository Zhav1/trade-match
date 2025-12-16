<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserPublicResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     * Filters sensitive information like email, phone, and exact location.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'profile_picture_url' => $this->profile_picture_url,
            'rating' => $this->average_rating ?? null,
            // SECURITY: Removed email, phone, google_id, default_lat, default_lon
            // to prevent data exposure (MASTER_ARCHITECTURE.md Issue #2)
        ];
    }
}
