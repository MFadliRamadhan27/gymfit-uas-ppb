class AppValidators {
  /// Validasi ID Member (Format: M001, M002, hingga M1000+)
  static String? validateMemberId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "ID Member wajib diisi";
    }
    
    // Regex memastikan diawali huruf M/m dan diikuti minimal 3 digit angka
    final regex = RegExp(r'^M\d{3,}$');
    if (!regex.hasMatch(value.trim().toUpperCase())) {
      return "Gunakan format M001 (Huruf M + minimal 3 angka)";
    }
    return null;
  }

  /// Validasi Nama Lengkap (Min 3 karakter, tanpa angka)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Nama Lengkap wajib diisi";
    }
    if (value.trim().length < 3) {
      return "Nama minimal terdiri dari 3 karakter";
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return "Nama tidak boleh mengandung angka";
    }
    return null;
  }

  /// Validasi Email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email wajib diisi";
    }
    final regex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return "Format email tidak valid (Contohnya: budi@gmail.com)";
    }
    return null;
  }

  /// Validasi No HP (Format Indonesia: diawali 08, panjang 11-13 digit)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "No. Handphone wajib diisi";
    }
    final regex = RegExp(r'^08\d{9,11}$');
    if (!regex.hasMatch(value.trim())) {
      return "Gunakan format 08xx (11-13 digit)";
    }
    return null;
  }

  /// Validasi Kode Pos (Tepat 5 digit angka)
  static String? validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Kode Pos wajib diisi";
    }
    final regex = RegExp(r'^[0-9]{5}$');
    if (!regex.hasMatch(value.trim())) {
      return "Kode Pos harus tepat 5 digit angka (Contohnya: 12345)";
    }
    return null;
  }

  /// Validasi Umum Kolom Wajib (Alamat, Kota, dll)
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName wajib diisi";
    }
    return null;
  }
}