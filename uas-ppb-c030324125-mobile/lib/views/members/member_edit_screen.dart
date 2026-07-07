import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/models/member_model.dart';
import '../../providers/member_provider.dart';

class MemberEditScreen extends StatefulWidget {
  final MemberModel member; // Menerima data member yang mau diedit

  const MemberEditScreen({super.key, required this.member});

  @override
  State<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idMemberController;
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _kotaController;
  late TextEditingController _kodePosController;
  late TextEditingController _emailController;
  late TextEditingController _noHpController;

  @override
  void initState() {
    super.initState();
    // Pre-fill / isi otomatis field dengan data member lama
    _idMemberController = TextEditingController(text: widget.member.idMember);
    _namaController = TextEditingController(text: widget.member.namaLengkap);
    _alamatController = TextEditingController(text: widget.member.alamat);
    _kotaController = TextEditingController(text: widget.member.kota);
    _kodePosController = TextEditingController(text: widget.member.kodePos);
    _emailController = TextEditingController(text: widget.member.email);
    _noHpController = TextEditingController(text: widget.member.noHp);
  }

  @override
  void dispose() {
    _idMemberController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _kotaController.dispose();
    _kodePosController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  void _updateData() async {
    if (!_formKey.currentState!.validate()) return;

    // Membuat objek model baru dengan data yang sudah diubah
    final updatedMember = MemberModel(
      id: widget.member.id, // ID internal database tidak berubah
      idMember: _idMemberController.text.trim(),
      namaLengkap: _namaController.text.trim(),
      alamat: _alamatController.text.trim(),
      kota: _kotaController.text.trim(),
      kodePos: _kodePosController.text.trim(),
      email: _emailController.text.trim(),
      noHp: _noHpController.text.trim(),
    );

    final provider = context.read<MemberProvider>();
    final success = await provider.updateMember(
      widget.member.id,
      updatedMember,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data member berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke list member
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.updateErrorMessage ?? "Gagal memperbarui member",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MemberProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        title: Text(
          "Edit Member",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff212529),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ID Member (Dibuat Disable agar tidak merusak relasi unik)
              _buildTextField(
                _idMemberController,
                "ID Member",
                Icons.badge_outlined,
                enabled: false, // Dikunci agar tidak bisa diedit
              ),
              _buildTextField(
                _namaController,
                "Nama Lengkap",
                Icons.person_outline,
              ),
              _buildTextField(
                _alamatController,
                "Alamat Lengkap",
                Icons.home_outlined,
              ),
              _buildTextField(
                _kotaController,
                "Kota",
                Icons.location_city_outlined,
              ),
              _buildTextField(
                _kodePosController,
                "Kode Pos",
                Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                _emailController,
                "Email",
                Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                _noHpController,
                "No. Handphone",
                Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              // Tombol Perbarui Data
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updateData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .orange, // Memakai warna oranye khas aksi sunting/edit
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Simpan Perubahan",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: enabled ? Colors.black87 : Colors.grey[600],
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? Colors.orange : Colors.grey,
            size: 22,
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.withAlpha(51)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.orange, width: 1.5),
          ),
          // Style tambahan untuk field yang disabled
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.withAlpha(51)),
          ),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? "$label wajib diisi" : null,
      ),
    );
  }
}
