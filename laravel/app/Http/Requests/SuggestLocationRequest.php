<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SuggestLocationRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Authorization handled by SwapPolicy in controller
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     * SECURITY: Validates coordinates and limits string lengths (MASTER_ARCHITECTURE.md Issue #5)
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'lat' => 'required|numeric|between:-90,90',
            'lng' => 'required|numeric|between:-180,180',
            'location_name' => 'required|string|max:255',
            'location_address' => 'required|string|max:500',
        ];
    }
}
