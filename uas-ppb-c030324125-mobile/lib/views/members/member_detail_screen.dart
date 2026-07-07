import 'package:flutter/material.dart';
import '../../data/models/member_model.dart';

class MemberDetailScreen extends StatelessWidget {
  final MemberModel member;

  const MemberDetailScreen({super.key, required this.member});

  // Helper untuk memformat string tanggal dari Laravel menjadi format Indonesia
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(dateStr);
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = months[dateTime.month - 1];
      return "$day $month ${dateTime.year}";
    } catch (e) {
      return dateStr; // Kembalikan string asli jika gagal parsing
    }
  }

  @override
  Widget build(BuildContext context) {
    final String inisial = member.namaLengkap.isNotEmpty
        ? member.namaLengkap[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detail Member',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ─── SECTION 1: AVATAR & IDENTITAS UTAMA ───
              Card(
                elevation: 0,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16.0,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue.shade800,
                          child: Text(
                            inisial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          member.namaLengkap,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade200.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            member.idMember,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ─── SECTION 2: DETAIL BIODATA MEMBER ───
              Card(
                elevation: 2,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                        child: Text(
                          'Informasi Kontak & Wilayah',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Divider(height: 1),

                      _buildDetailItem(
                        icon: Icons.email_rounded,
                        label: 'Email',
                        value: member.email,
                      ),
                      _buildDetailItem(
                        icon: Icons.phone_android_rounded,
                        label: 'Nomor HP',
                        value: member
                            .noHp, // Sesuaikan ke member.nomorHp jika itu nama variabelmu
                      ),
                      _buildDetailItem(
                        icon: Icons.location_on_rounded,
                        label: 'Alamat',
                        value: member.alamat,
                      ),
                      _buildDetailItem(
                        icon: Icons.location_city_rounded,
                        label: 'Kota',
                        value: member.kota,
                      ),
                      _buildDetailItem(
                        icon: Icons.local_post_office_rounded,
                        label: 'Kode Pos',
                        value: member.kodePos,
                      ),
                      _buildDetailItem(
                        icon: Icons.calendar_today_rounded,
                        label: 'Terdaftar Pada',
                        value: _formatDate(member.createdAt),
                        isLast: true,
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

  // Komponen Reusable untuk List Item Detail dengan gaya Modern
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue.shade700, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.isNotEmpty ? value : '-',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: Colors.grey[100], height: 1, indent: 56),
      ],
    );
  }
}
