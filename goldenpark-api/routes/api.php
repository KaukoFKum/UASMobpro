<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ResidentController;

Route::middleware('firebase')->apiResource('residents', ResidentController::class);
