<?php

return [

    'project_id' => env('FIREBASE_PROJECT_ID'),

    'public_keys_url' => env(
        'FIREBASE_PUBLIC_KEYS_URL',
        'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
    ),

    'public_keys_cache_file' => storage_path('framework/cache/firebase-public-keys.json'),

];
