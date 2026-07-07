import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  // 1. Langsung mengambil instance Dio dari Singleton ApiService tanpa variabel perantara
  final _dio = ApiService().dio;

  /// Fungsi Login dengan validasi error jaringan yang spesifik dan penyimpanan sesi lengkap
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final String token = response.data['access_token'];
        final Map<String, dynamic> userData = response.data['user'];

        // 2. Buka memori lokal dan amankan token beserta profil ringkas admin
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(AppConstants.userNameKey, userData['name'] ?? '');
        await prefs.setString(AppConstants.userEmailKey, userData['email'] ?? '');

        return {
          'success': true,
          'message': response.data['message'] ?? 'Login berhasil.',
          'user': UserModel.fromJson(userData),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Email atau password salah.',
        'errors': response.data['errors'],
      };

    } on DioException catch (e) {
      // 4. Deteksi spesifik jenis error koneksi untuk UX pengguna yang lebih bersahabat
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        return {
          'success': false,
          'message': 'Koneksi ke server timeout. Silakan coba lagi.',
        };
      }
      if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'Server tidak dapat dihubungi. Pastikan backend Laravel Anda aktif.',
        };
      }
      
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan jaringan.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal sistem lokal: $e',
      };
    }
  }

  /// Fungsi Logout untuk membersihkan seluruh sisa data sesi di perangkat HP
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/logout');

      if (response.statusCode == 200) {
        await _clearLocalSession();
        return {
          'success': true,
          'message': response.data['message'] ?? 'Berhasil logout.',
        };
      }
      return {'success': false, 'message': 'Gagal menghapus sesi di server.'};
    } catch (e) {
      // Jika token kedaluwarsa di server, tetap paksa bersihkan HP demi keamanan
      await _clearLocalSession();
      return {
        'success': true,
        'message': 'Sesi berakhir, penyimpanan lokal berhasil dibersihkan.',
      };
    }
  }

  /// 3. Helper internal untuk menghapus seluruh data sesi secara bersih
  Future<void> _clearLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userNameKey);
    await prefs.remove(AppConstants.userEmailKey);
  }
}