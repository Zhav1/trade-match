<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SendMessageRequest extends FormRequest
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
     * SECURITY: Limits message size to prevent massive payloads (MASTER_ARCHITECTURE.md Issue #5)
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'message_text' => 'required|string|max:1000',
        ];
    }
}
