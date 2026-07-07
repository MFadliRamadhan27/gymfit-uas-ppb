import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  UserModel? _user;
  String? _errorMessage;

  // Getter agar UI bisa membaca status tanpa mengubahnya secara langsung
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  /// Fungsi Aksi Login untuk UI
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Beritahu UI untuk menampilkan indikator loading

    final result = await _authService.login(email: email, password: password);

    _isLoading = false;
    if (result['success'] == true) {
      _isAuthenticated = true;
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _isAuthenticated = false;
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Fungsi Aksi Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();

    // Reset status setelah sukses logout
    _isAuthenticated = false;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Fitur Auto-Login: Memeriksa apakah token admin masih tersimpan di HP
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(AppConstants.tokenKey);
    final String? name = prefs.getString(AppConstants.userNameKey);
    final String? email = prefs.getString(AppConstants.userEmailKey);

    if (token != null && name != null && email != null) {
      _isAuthenticated = true;
      _user = UserModel(name: name, email: email);
    } else {
      _isAuthenticated = false;
      _user = null;
    }
    notifyListeners(); // Perbarui rute halaman utama secara otomatis
  }
}