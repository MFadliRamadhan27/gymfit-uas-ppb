<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Member;
use Carbon\Carbon;

class DashboardController extends Controller
{
    /**
     * Mengambil data agregasi statistik keanggotaan untuk visualisasi dasbor Flutter.
     */
    public function index()
    {
        // Menghitung total keseluruhan member yang tidak terhapus (Soft Delete)
        $totalMember = Member::count();

        // Menghitung jumlah member baru yang didaftarkan pada bulan berjalan saat ini
        $memberBaruBulanIni = Member::whereMonth('created_at', Carbon::now()->month)
                                    ->whereYear('created_at', Carbon::now()->year)
                                    ->count();

        // Mengambil 5 data member yang paling terakhir didaftarkan
        $memberTerbaru = Member::latest()->take(5)->get();

        return response()->json([
            'success' => true,
            'message' => 'Data statistik dasbor berhasil dimuat.',
            'data'    => [
                'total_member'          => $totalMember,
                'member_baru_bulan_ini' => $memberBaruBulanIni,
                'member_terbaru'        => $memberTerbaru
            ]
        ], 200);
    }
}