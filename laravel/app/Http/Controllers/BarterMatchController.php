<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BarterMatch;

class BarterMatchController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $matches = BarterMatch::whereHas('itemA.user', function ($query) use ($user) {
            $query->where('id', $user->id);
        })->orWhereHas('itemB.user', function ($query) use ($user) {
            $query->where('id', $user->id);
        })->with(['itemA.images', 'itemB.images', 'itemA.user', 'itemB.user'])->get();

        return response()->json($matches);
    }
}
