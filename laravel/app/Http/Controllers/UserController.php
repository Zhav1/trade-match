<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class UserController extends Controller
{
    /**
     * Update user profile information.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validatedData = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'phone' => ['sometimes', 'string', 'max:20'],
            'default_location_city' => ['sometimes', 'string', 'max:255'],
            'default_lat' => ['sometimes', 'numeric', 'between:-90,90'],
            'default_lon' => ['sometimes', 'numeric', 'between:-180,180'],
        ]);

        $user->update($validatedData);

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => $user
        ]);
    }

    /**
     * Upload user profile picture.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function uploadProfilePicture(Request $request): JsonResponse
    {
        $validatedData = $request->validate([
            'image' => ['required', 'image', 'mimes:jpeg,png,jpg', 'max:2048'], // 2MB max
        ]);

        $user = $request->user();

        // Delete old profile picture if exists
        if ($user->profile_picture_url) {
            $oldPath = str_replace('/storage/', '', $user->profile_picture_url);
            if (Storage::disk('public')->exists($oldPath)) {
                Storage::disk('public')->delete($oldPath);
            }
        }

        // Store new image
        $path = $request->file('image')->store('profile_pictures', 'public');
        $url = '/storage/' . $path;

        $user->profile_picture_url = $url;
        $user->save();

        return response()->json([
            'message' => 'Profile picture uploaded successfully',
            'user' => $user,
            'url' => $url
        ]);
    }
}
