<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | These defaults keep the API usable from Flutter web during local
    | development while still allowing production origins to be configured
    | explicitly through environment variables.
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => explode(',', env('CORS_ALLOWED_METHODS', 'GET,POST,PUT,PATCH,DELETE,OPTIONS')),

    'allowed_origins' => array_filter(explode(',', env('CORS_ALLOWED_ORIGINS', ''))),

    'allowed_origins_patterns' => array_filter(explode(',', env(
        'CORS_ALLOWED_ORIGINS_PATTERNS',
        '#^https?://(localhost|127\.0\.0\.1)(:\d+)?$#'
    ))),

    'allowed_headers' => explode(',', env('CORS_ALLOWED_HEADERS', '*')),

    'exposed_headers' => array_filter(explode(',', env('CORS_EXPOSED_HEADERS', ''))),

    'max_age' => (int) env('CORS_MAX_AGE', 0),

    'supports_credentials' => (bool) env('CORS_SUPPORTS_CREDENTIALS', false),

];
