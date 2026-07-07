<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\LoginRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    /**
     * Menangani autentikasi Admin menggunakan sistem bawaan Laravel dan menerbitkan token khusus.
     */
    public function login(LoginRequest $request)
    {
        // Menggunakan Auth::attempt untuk memverifikasi email dan password secara otomatis
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password yang Anda masukkan salah.'
            ], 401);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();

        // Mengamankan sesi tunggal dengan menegaskan tipe relasi ke VS Code
        /** @var \Illuminate\Database\Eloquent\Relations\HasMany $userTokens */
        $userTokens = $user->tokens();
        $userTokens->delete();

        // Menerbitkan token baru dengan nama konstanta spesifik proyek GymFit
        $token = $user->createToken('gymfit-mobile-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Autentikasi berhasil, selamat datang.',
            'access_token' => $token,
            'token_type'   => 'Bearer',
            'user'         => [
                'name'  => $user->name,
                'email' => $user->email
            ]
        ], 200);
    }

    /**
     * Mengambil data profil Admin yang saat ini sedang login (Endpoint /me).
     */
    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'message' => 'Data profil pengguna berhasil diambil.',
            'data'    => $request->user()
        ], 200);
    }

    /**
     * Mengakhiri sesi aktif dan menghapus token saat ini.
     */
    public function logout(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        
        // Menegaskan kepada VS Code bahwa token yang diambil adalah PersonalAccessToken
        /** @var \Laravel\Sanctum\PersonalAccessToken $token */
        $token = $user->currentAccessToken();
        $token->delete();

        return response()->json([
            'success' => true,
            'message' => 'Sesi berhasil diakhiri. Token akses telah dihapus.'
        ], 200);
    }
}