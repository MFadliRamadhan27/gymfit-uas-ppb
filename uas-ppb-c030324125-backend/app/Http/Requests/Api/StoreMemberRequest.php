<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class StoreMemberRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nama_lengkap' => 'required|string|max:100|regex:/^[A-Za-z\s\'.]+$/',
            'alamat'       => 'required|string',
            'kota'         => 'required|string|max:50',
            'kode_pos'     => 'required|numeric|digits:5',
            'email'        => 'required|email|max:100|unique:members,email',
            'no_hp'        => 'required|string|starts_with:08|min:11|max:13',
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique'       => 'Email sudah digunakan.',
            'nama_lengkap.regex' => 'Nama lengkap hanya boleh mengandung huruf, spasi, titik, atau tanda petik.',
            'no_hp.starts_with'  => 'Nomor HP harus diawali 08.',
            'kode_pos.digits'    => 'Kode pos harus 5 digit.',
        ];
    }
}