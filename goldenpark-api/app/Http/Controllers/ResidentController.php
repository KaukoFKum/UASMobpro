<?php

namespace App\Http\Controllers;

use App\Models\Resident;
use Illuminate\Http\Request;

class ResidentController extends Controller
{
    public function index()
    {
        $residents = Resident::latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Resident list retrieved successfully',
            'data' => $residents
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama' => 'required',
            'blok' => 'required',
            'nomor_rumah' => 'required',
            'no_hp' => 'required',
            'tanggal_masuk' => 'required',
            'status' => 'required',
        ]);

        $resident = Resident::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Resident created successfully',
            'data' => $resident
        ], 201);
    }

    public function show(string $id)
    {
        $resident = Resident::find($id);

        if (!$resident) {
            return response()->json([
                'success' => false,
                'message' => 'Resident not found',
                'data' => null
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Resident detail retrieved successfully',
            'data' => $resident
        ]);
    }

    public function update(Request $request, string $id)
    {
        $resident = Resident::find($id);

        if (!$resident) {
            return response()->json([
                'success' => false,
                'message' => 'Resident not found',
                'data' => null
            ], 404);
        }

        $validated = $request->validate([
            'nama' => 'required',
            'blok' => 'required',
            'nomor_rumah' => 'required',
            'no_hp' => 'required',
            'tanggal_masuk' => 'required',
            'status' => 'required',
        ]);

        $resident->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Resident updated successfully',
            'data' => $resident
        ]);
    }

    public function destroy(string $id)
    {
        $resident = Resident::find($id);

        if (!$resident) {
            return response()->json([
                'success' => false,
                'message' => 'Resident not found',
                'data' => null
            ], 404);
        }

        $resident->delete();

        return response()->json([
            'success' => true,
            'message' => 'Resident deleted successfully',
            'data' => null
        ]);
    }
}