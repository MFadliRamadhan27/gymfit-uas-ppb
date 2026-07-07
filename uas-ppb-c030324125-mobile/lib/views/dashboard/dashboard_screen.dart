import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../members/member_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Admin wajib memilih tombol
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Konfirmasi Keluar'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi GymFit?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext), // Menutup dialog (Batal)
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext); // Tutup dialog
                // Jalankan fungsi logout di provider
                context.read<AuthProvider>().logout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff212529),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('orang',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data admin yang sedang login dari AuthProvider
    final authProvider = context.watch<AuthProvider>();
    final adminName = authProvider.user?.name ?? 'Admin';
    final adminEmail = authProvider.user?.email ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        title: Text(
          "GymFit Dashboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff212529),
        elevation: 0,
        actions: [
          // Tombol Logout di pojok kanan atas AppBar
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Keluar Aplikasi',
            // Panggil dialog konfirmasi saat tombol ditekan
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.blueAccent,
        onRefresh: () async {
          await context.read<DashboardProvider>().fetchDashboardData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Selamat Datang & Profil Admin
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.indigoAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person_rounded,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat Datang 👋",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            adminName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            adminEmail,
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Consumer untuk data statistik dan member terbaru
              Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.memberTerbaru.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BARIS CARD STATISTIK UTAMA
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Member',
                              provider.totalMember.toString(),
                              Icons.people_rounded,
                              Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Bulan Ini',
                              provider.memberBaruBulanIni.toString(),
                              Icons.calendar_month_rounded,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // SUBJUDUL 5 MEMBER TERBARU
                      Text(
                        'Pendaftaran Member Terbaru',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff212529),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // LIST 5 MEMBER TERBARU
                      provider.memberTerbaru.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                  child: Text(
                                      'Belum ada riwayat pendaftaran member.')),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.memberTerbaru.length,
                              itemBuilder: (context, index) {
                                final m = provider.memberTerbaru[index];
                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueAccent[100],
                                    child: Text(
                                      m.namaLengkap.isNotEmpty
                                          ? m.namaLengkap[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent[700],
                                      ),
                                    ),
                                  ),
                                  title: Text(m.namaLengkap,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(m.idMember),
                                  trailing: Text(m.kota,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                );
                              },
                            ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Judul Menu Manajemen
              Text(
                "Menu Utama",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff212529),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Navigasi Menu Member Gym
              InkWell(
                onTap: () {
                  // Navigasi ke MemberListScreen akan kita pasang di sini setelah ini
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemberListScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.card_membership_rounded,
                          color: Colors.blueAccent,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kelola Member Gym",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff212529),
                              ),
                            ),
                            Text(
                              "Lihat daftar, tambah, edit, dan hapus data anggota",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
