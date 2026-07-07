import 'package:flutter/material.dart';
import 'dart:async'; // 🚀 Pastikan import ini ada di paling atas file
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/member_provider.dart';
import 'member_add_screen.dart';
import 'member_edit_screen.dart';
import 'member_detail_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Di dalam State class halaman kamu, deklarasikan satu variabel Timer:
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Memicu pengambilan data dari API Laravel sesaat setelah widget matang dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().fetchMembers();
    });
  }

  @override
  void dispose() {
    // ⚠️ Pastikan untuk meng-dispose timer saat halaman ditutup agar tidak memory leak:
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Dialog Konfirmasi sebelum benar-benar menghapus data dari DB Laravel
  void _showDeleteDialog(
    BuildContext context,
    MemberProvider provider,
    dynamic member,
  ) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Admin wajib memilih, tidak bisa asal klik luar layar
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text(
                "Hapus Member",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus member \"${member.namaLengkap}\"? Tindakan ini tidak dapat dibatalkan.",
          ),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                "Batal",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Tombol Hapus (Eksekusi)
            ElevatedButton(
              onPressed: () async {
                // 1. Tutup dialognya dulu
                Navigator.of(dialogContext).pop();

                // 2. Jalankan fungsi delete di provider
                bool success = await provider.deleteMember(member.id);

                // 3. Tampilkan Snackber umpan balik (Sukses / Gagal)
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? "Member \"${member.namaLengkap}\" berhasil dihapus!"
                            : (provider.fetchErrorMessage ??
                                  "Gagal menghapus member"),
                      ),
                      backgroundColor: success
                          ? Colors.green
                          : Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Hapus",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        title: Text(
          "Daftar Member Gym",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff212529),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari nama, ID, atau kota...',
                hintStyle: GoogleFonts.poppins(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MemberProvider>().fetchMembers(
                            search: '',
                          );
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.grey.withAlpha(77)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.grey.withAlpha(77)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (value) {
                // Jika admin masih mengetik, batalkan timer sebelumnya
                if (_debounce?.isActive ?? false) _debounce!.cancel();

                // Buat timer baru dengan jeda 300 milidetik
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  // Jalankan request API setelah admin berhenti mengetik selama 300ms
                  context.read<MemberProvider>().fetchMembers(search: value);
                });

                setState(() {}); // Untuk memperbarui ikon silang (clear button)
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<MemberProvider>().fetchMembers(
                search: _searchController.text,
              ),
              child: _buildBody(memberProvider),
            ),
          ),
        ],
      ),
      // Tombol Mengambang untuk Tambah Member Baru
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MemberAddScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(MemberProvider memberProvider) {
    if (memberProvider.isLoading && memberProvider.members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              "Memuat data...",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (memberProvider.fetchErrorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "Gagal mengambil data",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                memberProvider.fetchErrorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<MemberProvider>().fetchMembers(
                  search: _searchController.text,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }

    if (memberProvider.members.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: memberProvider.members.length,
      itemBuilder: (context, index) {
        final member = memberProvider.members[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withAlpha(51)),
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberDetailScreen(member: member),
                ),
              );
            },
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.withAlpha(26),
              child: Text(
                member.namaLengkap.isNotEmpty
                    ? member.namaLengkap.substring(0, 1).toUpperCase()
                    : '?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ), // Penutup untuk CircleAvatar
            title: Text(
              member.namaLengkap,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  member.idMember,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.kota,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.noHp,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Edit - SEKARANG SUDAH AKTIF AKTIF
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                  onPressed: () {
                    // Navigasi ke halaman edit dengan membawa data member terpilih
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemberEditScreen(member: member),
                      ),
                    );
                  },
                ),
                // Tombol Hapus Berdialog
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  onPressed: () =>
                      _showDeleteDialog(context, memberProvider, member),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isNotEmpty
                ? Icons.person_search_rounded
                : Icons.people_outline_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'Member tidak ditemukan'
                : 'Belum ada data member',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchController.text.isNotEmpty
                ? 'Coba gunakan kata kunci lain'
                : 'Silakan tambahkan member baru untuk memulai',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
