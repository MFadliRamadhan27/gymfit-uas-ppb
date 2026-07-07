import 'package:flutter/material.dart';
import '../data/models/member_model.dart';
import '../data/services/member_service.dart';

class MemberProvider with ChangeNotifier {
  final MemberService _memberService = MemberService();

  List<MemberModel> _members = [];
  bool _isLoading = false;
  // 🌟 SEPARASI: Pisahkan error untuk ambil data dan tambah data
  String? _fetchErrorMessage; // Khusus halaman daftar member
  String? _addErrorMessage; // Khusus halaman tambah member
  String? _updateErrorMessage; // Khusus halaman edit member
  Map<String, dynamic> _errors = {};

  // Getter agar data bisa dibaca oleh UI tanpa mengubahnya secara langsung
  List<MemberModel> get members => _members;
  bool get isLoading => _isLoading;
  String? get fetchErrorMessage => _fetchErrorMessage; // Getter baru
  String? get addErrorMessage => _addErrorMessage;
  String? get updateErrorMessage => _updateErrorMessage;
  Map<String, dynamic> get errors => _errors;

  /// Fungsi untuk membersihkan error form saat berpindah halaman
  void clearAddErrors() {
    _addErrorMessage = null;
    _errors = {};
    notifyListeners();
  }

  /// Fungsi internal untuk menerjemahkan error unique dari Laravel ke Bahasa Indonesia
  String _translateLaravelError(String field, String originalMessage) {
    final msg = originalMessage.toLowerCase();

    // Deteksi jika data sudah terpakai (Validation Rule: unique)
    if (msg.contains('has already been taken') || msg.contains('sudah ada')) {
      if (field == 'id_member' || field == 'idMember') {
        return "ID Member sudah digunakan.";
      }
      if (field == 'email') {
        return "Email sudah terdaftar, silakan gunakan email lain!";
      }
      return "Data pada kolom $field sudah digunakan!";
    }

    return originalMessage; // Kembalikan pesan asli jika tidak ada kecocokan
  }

  /// 1. AMBIL DATA (FETCH): Menarik semua data member dari API Laravel
  Future<void> fetchMembers({String search = ''}) async {
    _isLoading = true;
    _fetchErrorMessage = null; // Gunakan fetch error
    notifyListeners(); // Pasang loading memutar di layar HP

    final result = await _memberService.getMembers(search: search);

    _isLoading = false;
    if (result['success'] == true) {
      _members = result['data'];
    } else {
      _fetchErrorMessage = result['message']; // Gunakan fetch error
    }
    notifyListeners(); // Perbarui tampilan list member terbaru
  }

  /// 2. TAMBAH DATA (CREATE): Mengirim member baru ke database lewat API
  Future<bool> addMember(MemberModel member) async {
    _isLoading = true;
    _addErrorMessage = null; // Gunakan add error
    _errors = {}; // Selalu bersihkan error lama setiap kali fungsi dipanggil
    notifyListeners();

    final result = await _memberService.createMember(member);

    _isLoading = false;
    if (result['success'] == true) {
      // Masukkan data respons dari backend ke dalam list lokal agar UI langsung ter-update
      _members.add(result['data']);
      notifyListeners();
      return true;
    } else {
      // Jika terjadi error validasi backend (Laravel mendeteksi data duplikat/invalid)
      if (result['errors'] != null) {
        _errors = result['errors'];

        // Ambil key field pertama yang error (misal: 'id_member' atau 'email')
        String firstKey = _errors.keys.first;
        String firstErrorMessage = _errors[firstKey][0].toString();

        // Terjemahkan pesan error pertama tersebut untuk ditampilkan di Snackbar
        _addErrorMessage = _translateLaravelError(
          firstKey,
          firstErrorMessage,
        ); // Gunakan add error
      } else {
        _addErrorMessage = result['message'] ?? "Gagal menambahkan member";
      }

      notifyListeners();
      return false;
    }
  }

  /// 3. EDIT DATA (UPDATE): Memperbarui data member lama
  Future<bool> updateMember(int id, MemberModel updatedMember) async {
    _isLoading = true;
    _updateErrorMessage = null;
    notifyListeners();

    final result = await _memberService.updateMember(id, updatedMember);

    _isLoading = false;
    if (result['success'] == true) {
      // Cari posisi index data lama di list lokal, lalu timpa dengan data baru
      final index = _members.indexWhere((element) => element.id == id);
      if (index != -1) {
        _members[index] = result['data'];
      }
      notifyListeners();
      return true;
    } else {
      _updateErrorMessage = result['message'] ?? "Gagal memperbarui member";
      notifyListeners();
      return false;
    }
  }

  /// 4. HAPUS DATA (DELETE): Menghapus member dari database berdasarkan ID
  Future<bool> deleteMember(int id) async {
    _isLoading = true;
    _fetchErrorMessage = null; // Error hapus akan tampil di halaman list
    notifyListeners();

    final result = await _memberService.deleteMember(id);

    _isLoading = false;
    if (result['success'] == true) {
      // Hapus data dari list lokal secara instan tanpa perlu reload dari internet
      _members.removeWhere((element) => element.id == id);
      notifyListeners();
      return true;
    } else {
      _fetchErrorMessage =
          result['message'] as String? ?? "Gagal menghapus member";
      notifyListeners();
      return false;
    }
  }
}
