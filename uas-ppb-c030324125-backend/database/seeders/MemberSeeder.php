<?php

namespace Database\Seeders;

use App\Models\Member;
use Illuminate\Database\Seeder;

class MemberSeeder extends Seeder
{
    public function run(): void
    {
        $dataMember = [
            [
                'id_member'    => 'M001',
                'nama_lengkap' => 'M. Fadli Ramadhan',
                'alamat'       => 'Jl. Brigjend H. Hasan Basri',
                'kota'         => 'Banjarmasin',
                'kode_pos'     => '70123',
                'email'        => 'fadli@gymfit.com',
                'no_hp'        => '081234567890',
            ],
            [
                'id_member'    => 'M002',
                'nama_lengkap' => 'Achmad Rinaldi',
                'alamat'       => 'Jl. Ahmad Yani KM 5',
                'kota'         => 'Banjarmasin',
                'kode_pos'     => '70234',
                'email'        => 'rinaldi@gymfit.com',
                'no_hp'        => '082198765432',
            ],
            [
                'id_member'    => 'M003',
                'nama_lengkap' => 'Siti Aminah',
                'alamat'       => 'Jl. Panglima Batur',
                'kota'         => 'Banjarbaru',
                'kode_pos'     => '70711',
                'email'        => 'aminah@gymfit.com',
                'no_hp'        => '085344556677',
            ],
        ];

        foreach ($dataMember as $member) {
            Member::updateOrCreate(
                ['id_member' => $member['id_member']], // Kunci keunikan pengecekan
                $member
            );
        }
    }
}