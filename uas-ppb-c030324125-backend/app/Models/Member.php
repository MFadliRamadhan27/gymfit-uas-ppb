<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model; 

class Member extends Model
{

    protected $table = 'members';

    protected $fillable = [
        'id_member',
        'nama_lengkap',
        'alamat',
        'kota',
        'kode_pos',
        'email',
        'no_hp'
    ];
}