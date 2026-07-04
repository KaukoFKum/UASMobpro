<?php

namespace App\Http\Middleware;

use App\Services\Firebase\FirebaseTokenVerifier;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

class VerifyFirebaseToken
{
    public function __construct(
        private readonly FirebaseTokenVerifier $verifier
    ) {
    }

    public function handle(Request $request, Closure $next): Response
    {
        $bearerToken = $request->bearerToken();

        if (! $bearerToken) {
            return response()->json([
                'success' => false,
                'message' => 'Firebase bearer token is required',
                'data' => null,
            ], 401);
        }

        if (! is_string(config('firebase.project_id')) || config('firebase.project_id') === '') {
            return response()->json([
                'success' => false,
                'message' => 'Firebase authentication is not configured',
                'data' => null,
            ], 500);
        }

        try {
            $firebaseUser = $this->verifier->verify($bearerToken);
        } catch (Throwable) {
            return response()->json([
                'success' => false,
                'message' => 'Firebase bearer token is invalid',
                'data' => null,
            ], 401);
        }

        $request->attributes->set('firebase_user', $firebaseUser);
        $request->attributes->set('firebase_uid', $firebaseUser['sub']);

        return $next($request);
    }
}
