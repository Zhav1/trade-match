<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ImageUploadController extends Controller
{
    /**
     * Handle an image upload.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function upload(Request $request): JsonResponse
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        // For now, we'll just return a dummy URL.
        // In a real application, you would store the image and return the actual URL.
        $dummyUrl = 'https://via.placeholder.com/150';

        return response()->json(['url' => $dummyUrl]);
    }
}
