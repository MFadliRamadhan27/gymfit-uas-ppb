<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Menjalankan proses pengisian data awal database secara terpusat.
     */
    public function run(): void
    {
        // Mendaftarkan Akun Admin Utama secara aman dan idempoten
        User::updateOrCreate(
            ['email' => 'admin@gymfit.com'], // Pengecekan berbasis alamat email unik
            [
                'name'     => 'Admin GymFit',
                'password' => Hash::make('password123'),
            ]
        );

        // Memanggil Seeder komponen Member yang telah dibuat
        $this->call([
            MemberSeeder::class,
        ]);
    }
}