<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CreateItemRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Authorization is handled by middleware (auth:sanctum)
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     * SECURITY: Enforces max sizes to prevent DoS attacks (MASTER_ARCHITECTURE.md Issue #5)
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'title' => 'required|string|max:100',
            'description' => 'required|string|max:2000',
            'category_id' => 'required|exists:categories,id',
            'condition' => ['required', Rule::in(['new', 'like_new', 'good', 'fair'])],
            'estimated_value' => 'nullable|numeric|min:0|max:10000000',
            'currency' => 'required|string|size:3',
            'location_city' => 'required|string|max:255',
            'location_lat' => 'required|numeric|between:-90,90',
            'location_lon' => 'required|numeric|between:-180,180',
            'wants_description' => 'nullable|string|max:500',
            'image_urls' => 'required|array|max:10', // Max 10 images per item
            'image_urls.*' => 'url|max:500',
            'wanted_category_ids' => 'nullable|array|max:5', // Max 5 wanted categories
            'wanted_category_ids.*' => 'exists:categories,id',
        ];
    }
}
