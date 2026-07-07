<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateMemberRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        // 🚀 Mengatasi Route Model Binding dengan aman
        $member = $this->route('member');
        $memberId = is_object($member) ? $member->id : $member;

        return [
            'id_member'    => 'required|string|max:20|unique:members,id_member,' . $memberId,
            'nama_lengkap' => 'required|string|max:100|regex:/^[A-Za-z\s\'.]+$/',
            'alamat'       => 'required|string',
            'kota'         => 'required|string|max:50',
            'kode_pos'     => 'required|numeric|digits:5',
            'email'        => 'required|email|max:100|unique:members,email,' . $memberId,
            'no_hp'        => 'required|string|starts_with:08|min:11|max:13',
        ];
    }

    public function messages(): array
    {
        return [
            'id_member.unique'   => 'ID Member sudah digunakan.',
            'email.unique'       => 'Email sudah digunakan oleh member lain.',
            'nama_lengkap.regex' => 'Nama lengkap hanya boleh mengandung huruf, spasi, titik, atau tanda petik.',
            'no_hp.starts_with'  => 'Nomor HP harus diawali 08.',
            'kode_pos.digits'    => 'Kode pos harus 5 digit.',
        ];
    }
}