<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Member;
use Illuminate\Http\Request;

class MemberController extends Controller
{
    /**
     * Menampilkan semua data member.
     */
   public function index(Request $request)
    {
        $query = Member::query();

        if ($request->filled('search')) {
            $search = $request->search;

            $query->where(function ($q) use ($search) {
                $q->where('nama_lengkap', 'like', "%{$search}%")
                ->orWhere('id_member', 'like', "%{$search}%")
                ->orWhere('kota', 'like', "%{$search}%");
            });
        }

        $members = $query->latest('id')->get();

        return response()->json([
            'success' => true,
            'data'    => $members
        ], 200);
    }

    /**
     * Menyimpan member baru dengan ID otomatis.
     */
    public function store(Request $request)
    {
        // 1. Validasi Input dari Flutter (Tanpa id_member)
        $request->validate([
            'nama_lengkap'     => 'required|string|max:255',
            'alamat'   => 'required|string',
            'kota'     => 'required|string|max:100',
            'kode_pos' => 'required|string|max:10',
            'email'    => 'required|email|unique:members,email',
            'no_hp'    => 'required|string|max:20',
        ]);

        try {
            // 2. Logika Auto-Generate ID Member (M001, M002, M003, dst.)
            $lastMember = Member::orderBy('id', 'desc')->first();

            if (!$lastMember) {
                $nextId = 'M001'; // Jika database masih kosong
            } else {
                // Mengambil angka setelah huruf 'M' (misal 'M023' menjadi integer 23)
                $lastNumber = (int) substr($lastMember->id_member, 1);
                // Menambahkan 1 dan memformat ulang dengan padding 3 digit (M024)
                $nextId = 'M' . str_pad($lastNumber + 1, 3, '0', STR_PAD_LEFT);
            }

            // 3. Simpan data ke Database MySQL
            $member = Member::create([
                'id_member' => $nextId,
                'nama_lengkap'      => $request->nama_lengkap,
                'alamat'    => $request->alamat,
                'kota'      => $request->kota,
                'kode_pos'  => $request->kode_pos,
                'email'     => $request->email,
                'no_hp'     => $request->no_hp,
            ]);

            // 4. Return response sukses ke Flutter
            return response()->json([
                'success' => true,
                'message' => 'Member berhasil ditambahkan dengan ID ' . $nextId,
                'data'    => $member
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menambah data member: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Menampilkan detail satu member.
     */
    public function show(Member $member)
    {
        return response()->json($member);
    }

    /**
     * Memperbarui data member.
     */
    public function update(Request $request, Member $member)
    {
        $request->validate([
            'nama_lengkap'     => 'required|string|max:255',
            'alamat'   => 'required|string',
            'kota'     => 'required|string|max:100',
            'kode_pos' => 'required|string|max:10',
            // Validasi email unik, tapi abaikan email milik member itu sendiri
            'email'    => 'required|email|unique:members,email,' . $member->id,
            'no_hp'    => 'required|string|max:20',
        ]);

        $member->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Data member berhasil diperbarui',
            'data'    => $member
        ]);
    }

    /**
     * Menghapus data member (Soft Delete).
     */
    public function destroy(Member $member)
    {
        if (!$member) {
            return response()->json([
                'success' => false,
                'message' => 'Data member tidak ditemukan.'
            ], 404);
        }

        $member->delete(); // Ini akan menjalankan Soft Delete

        return response()->json([
            'success' => true,
            'message' => 'Member berhasil dihapus.'
        ]);
    }
}
