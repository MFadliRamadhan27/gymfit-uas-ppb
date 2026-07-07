import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/models/member_model.dart';
import '../../providers/member_provider.dart';
import '../../utils/validators.dart';

class MemberAddScreen extends StatefulWidget {
  const MemberAddScreen({super.key});

  @override
  State<MemberAddScreen> createState() => _MemberAddScreenState();
}

class _MemberAddScreenState extends State<MemberAddScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller input teks
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kotaController = TextEditingController();
  final _kodePosController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Bersihkan state error form dari sesi sebelumnya saat halaman dibuka
    context.read<MemberProvider>().clearAddErrors();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _kotaController.dispose();
    _kodePosController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    super.dispose();

    // 🌟 Membersihkan error saat meninggalkan halaman
    // context.read<MemberProvider>().clearAddErrors();
  }

  /// Fungsi untuk membersihkan semua inputan form (Reset)
  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _alamatController.clear();
    _kotaController.clear();
    _kodePosController.clear();
    _emailController.clear();
    _noHpController.clear();

    // 🌟 TAMBAHAN: Bersihkan juga error validasi dari provider
    context.read<MemberProvider>().clearAddErrors();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Formulir berhasil dikosongkan"),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// Fungsi untuk memproses pengiriman data ke Laravel
  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    final newMember = MemberModel(
      id: 0,
      idMember: '', // Dikosongkan karena akan di-generate oleh backend
      namaLengkap: _namaController.text.trim(),
      alamat: _alamatController.text.trim(),
      kota: _kotaController.text.trim(),
      kodePos: _kodePosController.text.trim(),
      email: _emailController.text.trim(),
      noHp: _noHpController.text.trim(),
    );

    final provider = context.read<MemberProvider>();
    final success = await provider.addMember(newMember);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Member baru berhasil ditambahkan!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.addErrorMessage ?? "Gagal menambahkan member"),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MemberProvider>().isLoading;
    // Ambil state provider & map error terbarunya
    final memberProvider = context.watch<MemberProvider>();
    final backendErrors = memberProvider.errors;
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        title: Text(
          "Tambah Member",
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
              // 2. Nama
              _buildTextField(
                _namaController,
                "Nama Lengkap",
                Icons.person_outline,
                validator: AppValidators.validateName,
                errorText: backendErrors['nama_lengkap'] != null
                    ? backendErrors['nama_lengkap'][0]
                    : null,
              ),

              // 3. Alamat
              _buildTextField(
                _alamatController,
                "Alamat Lengkap",
                Icons.home_outlined,
                validator: (val) =>
                    AppValidators.validateRequired(val, "Alamat Lengkap"),
                errorText: backendErrors['alamat'] != null
                    ? backendErrors['alamat'][0]
                    : null,
              ),

              // 4. Kota
              _buildTextField(
                _kotaController,
                "Kota",
                Icons.location_city_outlined,
                validator: (val) => AppValidators.validateRequired(val, "Kota"),
                errorText: backendErrors['kota'] != null
                    ? backendErrors['kota'][0]
                    : null,
              ),

              // 5. Kode Pos
              _buildTextField(
                _kodePosController,
                "Kode Pos",
                Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
                validator: AppValidators.validatePostalCode,
                errorText: backendErrors['kode_pos'] != null
                    ? backendErrors['kode_pos'][0]
                    : null,
              ),

              // 6. Email
              _buildTextField(
                _emailController,
                "Email",
                Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: AppValidators.validateEmail,
                errorText: backendErrors['email'] != null
                    ? backendErrors['email'][0]
                    : null,
              ),

              // 7. No HP
              _buildTextField(
                _noHpController,
                "No. Handphone",
                Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                validator: AppValidators.validatePhone,
                errorText: backendErrors['no_hp'] != null
                    ? backendErrors['no_hp'][0]
                    : null,
              ),

              const SizedBox(height: 24),

              // Layout dua tombol aksi berdampingan
              Row(
                children: [
                  // Tombol Simpan (Primary Action)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
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
                                "Simpan Member",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Tombol Reset (Secondary Action)
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : _resetForm,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Reset",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
    String? Function(String?)? validator,
    String? errorText, // Tambahkan parameter opsional ini
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
          errorText: errorText, // Pasangkan ke properti errorText TextFormField
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? Colors.blueAccent : Colors.grey,
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
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
