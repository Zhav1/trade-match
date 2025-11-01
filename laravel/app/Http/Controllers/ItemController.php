<?php

namespace App\Http\Controllers;

use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Gate;

class ItemController extends Controller
{
    /**
     * Display a listing of the authenticated user's items.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $items = $request->user()->items()
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'items' => $items
        ]);
    }

    /**
     * Store a newly created item.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        $validatedData = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'lat' => ['nullable', 'numeric'],
            'lng' => ['nullable', 'numeric'],
        ]);

        $item = $request->user()->items()->create($validatedData);

        return response()->json([
            'message' => 'Item created successfully',
            'item' => $item
        ], 201);
    }

    /**
     * Display the specified item.
     *
     * @param Request $request
     * @param Item $item
     * @return JsonResponse
     */
    public function show(Request $request, Item $item): JsonResponse
    {
        if ($request->user()->id !== $item->user_id) {
            return response()->json([
                'message' => 'You are not authorized to view this item'
            ], 403);
        }

        return response()->json([
            'item' => $item
        ]);
    }

    /**
     * Update the specified item.
     *
     * @param Request $request
     * @param Item $item
     * @return JsonResponse
     */
    public function update(Request $request, Item $item): JsonResponse
    {
        if ($request->user()->id !== $item->user_id) {
            return response()->json([
                'message' => 'You are not authorized to update this item'
            ], 403);
        }

        $validatedData = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'lat' => ['nullable', 'numeric'],
            'lng' => ['nullable', 'numeric'],
        ]);

        $item->update($validatedData);

        return response()->json([
            'message' => 'Item updated successfully',
            'item' => $item
        ]);
    }

    /**
     * Remove the specified item.
     *
     * @param Request $request
     * @param Item $item
     * @return JsonResponse|Response
     */
    public function destroy(Request $request, Item $item): JsonResponse|Response
    {
        if ($request->user()->id !== $item->user_id) {
            return response()->json([
                'message' => 'You are not authorized to delete this item'
            ], 403);
        }

        $item->delete();

        return response()->noContent();
    }
}