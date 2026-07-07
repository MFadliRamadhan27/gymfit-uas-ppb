<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\MemberController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Rute Publik (Akses Tanpa Autentikasi Token)
Route::post('/login', [AuthController::class, 'login']);

// Rute Terproteksi (Wajib Menyertakan Bearer Token yang Sah)
Route::middleware('auth:sanctum')->group(function () {
    
    // Endpoint Profil Pengguna yang Sedang Login
    Route::get('/me', [AuthController::class, 'me']);
    
    // Endpoint Statistik Dasbor Utama GymFit
    Route::get('/dashboard', [DashboardController::class, 'index']);
    
    // Endpoint Operasi CRUD Data Member GymFit
    Route::apiResource('members', MemberController::class);
    
    // Endpoint Mengakhiri Sesi Serta Penghapusan Token
    Route::post('/logout', [AuthController::class, 'logout']);
    
});