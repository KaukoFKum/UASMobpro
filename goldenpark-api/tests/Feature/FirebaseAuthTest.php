<?php

namespace Tests\Feature;

use Tests\TestCase;

class FirebaseAuthTest extends TestCase
{
    public function test_residents_api_requires_a_firebase_bearer_token(): void
    {
        $response = $this->getJson('/api/residents');

        $response->assertUnauthorized()
            ->assertJson([
                'success' => false,
                'message' => 'Firebase bearer token is required',
                'data' => null,
            ]);
    }

    public function test_residents_api_rejects_an_invalid_firebase_bearer_token(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer invalid-token')
            ->getJson('/api/residents');

        $response->assertUnauthorized()
            ->assertJson([
                'success' => false,
                'message' => 'Firebase bearer token is invalid',
                'data' => null,
            ]);
    }
}
