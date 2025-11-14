<?php

namespace App\Http\Controllers;

use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\DB;

class ItemController extends Controller
{
    /**
     * Display a listing of the authenticated user's items.
     */
    public function index(Request $request): JsonResponse
    {
        $items = $request->user()->items()
            ->with(['category', 'images', 'wants.category'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json(['items' => $items]);
    }

    /**
     * Store a newly created item.
     */
    public function store(Request $request): JsonResponse
    {
        $validatedData = $request->validate([
            'category_id' => 'required|exists:categories,id',
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'condition' => ['required', Rule::in(['new', 'like_new', 'good', 'fair'])],
            'estimated_value' => 'nullable|numeric|min:0',
            'currency' => 'required|string|size:3',
            'location_city' => 'required|string|max:255',
            'location_lat' => 'required|numeric',
            'location_lon' => 'required|numeric',
            'wants_description' => 'nullable|string',
            'image_urls' => 'required|array',
            'image_urls.*' => 'url',
            'wanted_category_ids' => 'array',
            'wanted_category_ids.*' => 'exists:categories,id',
        ]);

        $item = null;

        DB::transaction(function () use ($request, $validatedData, &$item) {
            $item = $request->user()->items()->create([
                'category_id' => $validatedData['category_id'],
                'title' => $validatedData['title'],
                'description' => $validatedData['description'],
                'condition' => $validatedData['condition'],
                'estimated_value' => $validatedData['estimated_value'],
                'currency' => $validatedData['currency'],
                'location_city' => $validatedData['location_city'],
                'location_lat' => $validatedData['location_lat'],
                'location_lon' => $validatedData['location_lon'],
                'wants_description' => $validatedData['wants_description'],
                'status' => 'active',
            ]);

            if (isset($validatedData['image_urls'])) {
                $images = [];
                foreach ($validatedData['image_urls'] as $index => $url) {
                    $images[] = [
                        'image_url' => $url,
                        'sort_order' => $index,
                    ];
                }
                $item->images()->createMany($images);
            }

            if (isset($validatedData['wanted_category_ids'])) {
                $wants = [];
                foreach ($validatedData['wanted_category_ids'] as $id) {
                    $wants[] = ['wanted_category_id' => $id];
                }
                $item->wants()->createMany($wants);
            }
        });

        $item->load(['category', 'images', 'wants.category']);

        return response()->json([
            'message' => 'Item created successfully',
            'item' => $item
        ], 201);
    }

    /**
     * Display the specified item.
     */
    public function show(Item $item): JsonResponse
    {
        // Authorization can be handled by a policy
        $this->authorize('view', $item);

        $item->load(['user', 'category', 'images', 'wants.category']);

        return response()->json(['item' => $item]);
    }

    /**
     * Update the specified item.
     */
    public function update(Request $request, Item $item): JsonResponse
    {
        $this->authorize('update', $item);

        $validatedData = $request->validate([
            'category_id' => 'sometimes|required|exists:categories,id',
            'title' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'condition' => ['sometimes', 'required', Rule::in(['new', 'like_new', 'good', 'fair'])],
            'estimated_value' => 'nullable|numeric|min:0',
            'currency' => 'sometimes|required|string|size:3',
            'location_city' => 'sometimes|required|string|max:255',
            'location_lat' => 'sometimes|required|numeric',
            'location_lon' => 'sometimes|required|numeric',
            'wants_description' => 'nullable|string',
            'status' => ['sometimes', 'required', Rule::in(['active', 'pending', 'traded', 'hidden'])],
        ]);

        $item->update($validatedData);

        $item->load(['user', 'category', 'images', 'wants.category']);

        return response()->json([
            'message' => 'Item updated successfully',
            'item' => $item
        ]);
    }

    /**
     * Remove the specified item.
     */
    public function destroy(Item $item): Response
    {
        $this->authorize('delete', $item);

        $item->delete();

        return response()->noContent();
    }
}