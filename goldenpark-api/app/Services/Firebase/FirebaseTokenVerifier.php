<?php

namespace App\Services\Firebase;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Illuminate\Support\Facades\Http;
use RuntimeException;
use Throwable;

class FirebaseTokenVerifier
{
    public function verify(string $idToken): array
    {
        $projectId = config('firebase.project_id');

        if (! is_string($projectId) || $projectId === '') {
            throw new RuntimeException('Firebase project ID is not configured.');
        }

        $headers = $this->decodeHeaders($idToken);
        $kid = $headers['kid'] ?? null;

        if (! is_string($kid) || $kid === '') {
            throw new RuntimeException('Firebase token is missing a key ID.');
        }

        $publicKeys = $this->publicKeys();

        if (! isset($publicKeys[$kid])) {
            $this->forgetCachedPublicKeys();
            $publicKeys = $this->publicKeys();
        }

        if (! isset($publicKeys[$kid])) {
            throw new RuntimeException('Firebase public key was not found.');
        }

        $payload = (array) JWT::decode($idToken, new Key($publicKeys[$kid], 'RS256'));

        $this->validatePayload($payload, $projectId);

        return $payload;
    }

    private function decodeHeaders(string $idToken): array
    {
        $parts = explode('.', $idToken);

        if (count($parts) !== 3) {
            throw new RuntimeException('Firebase token has an invalid format.');
        }

        $decoded = json_decode($this->base64UrlDecode($parts[0]), true);

        if (! is_array($decoded)) {
            throw new RuntimeException('Firebase token headers are invalid.');
        }

        return $decoded;
    }

    private function base64UrlDecode(string $value): string
    {
        $base64 = strtr($value, '-_', '+/');
        $padding = (4 - strlen($base64) % 4) % 4;
        $padded = $base64.str_repeat('=', $padding);

        $decoded = base64_decode($padded, true);

        if ($decoded === false) {
            throw new RuntimeException('Firebase token contains invalid base64.');
        }

        return $decoded;
    }

    private function publicKeys(): array
    {
        $cached = $this->cachedPublicKeys();

        if ($cached !== null) {
            return $cached;
        }

        $response = Http::timeout(10)->get(config('firebase.public_keys_url'));

        if (! $response->ok()) {
            throw new RuntimeException('Unable to retrieve Firebase public keys.');
        }

        $publicKeys = $response->json();

        if (! is_array($publicKeys)) {
            throw new RuntimeException('Firebase public keys response is invalid.');
        }

        $maxAge = $this->maxAgeFromCacheControl($response->header('Cache-Control'));

        $this->cachePublicKeys($publicKeys, $maxAge);

        return $publicKeys;
    }

    private function cachedPublicKeys(): ?array
    {
        $path = config('firebase.public_keys_cache_file');

        if (! is_string($path) || ! is_file($path)) {
            return null;
        }

        try {
            $payload = json_decode((string) file_get_contents($path), true);
        } catch (Throwable) {
            return null;
        }

        if (
            ! is_array($payload)
            || ! isset($payload['expires_at'], $payload['keys'])
            || ! is_int($payload['expires_at'])
            || ! is_array($payload['keys'])
            || $payload['expires_at'] <= time()
        ) {
            return null;
        }

        return $payload['keys'];
    }

    private function cachePublicKeys(array $publicKeys, int $maxAge): void
    {
        $path = config('firebase.public_keys_cache_file');

        if (! is_string($path)) {
            return;
        }

        $directory = dirname($path);

        if (! is_dir($directory)) {
            mkdir($directory, 0775, true);
        }

        file_put_contents($path, json_encode([
            'expires_at' => time() + $maxAge,
            'keys' => $publicKeys,
        ]));
    }

    private function forgetCachedPublicKeys(): void
    {
        $path = config('firebase.public_keys_cache_file');

        if (is_string($path) && is_file($path)) {
            unlink($path);
        }
    }

    private function maxAgeFromCacheControl(?string $cacheControl): int
    {
        if (is_string($cacheControl) && preg_match('/max-age=(\d+)/', $cacheControl, $matches)) {
            return max(60, (int) $matches[1]);
        }

        return 3600;
    }

    private function validatePayload(array $payload, string $projectId): void
    {
        $issuer = 'https://securetoken.google.com/'.$projectId;

        if (($payload['aud'] ?? null) !== $projectId) {
            throw new RuntimeException('Firebase token audience is invalid.');
        }

        if (($payload['iss'] ?? null) !== $issuer) {
            throw new RuntimeException('Firebase token issuer is invalid.');
        }

        if (! isset($payload['sub']) || ! is_string($payload['sub']) || $payload['sub'] === '') {
            throw new RuntimeException('Firebase token subject is invalid.');
        }
    }
}
