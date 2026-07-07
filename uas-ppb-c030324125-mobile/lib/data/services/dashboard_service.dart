import 'package:dio/dio.dart';
import 'api_service.dart';

class DashboardService {
  final Dio _dio = ApiService().dio;

  /// Mengambil data agregasi statistik dan list member terbaru dari API Laravel.
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _dio.get('/dashboard');

      // Mengembalikan data JSON yang dikirim oleh Laravel
      return response.data;
    } on DioException catch (e) {
      // Menangani error spesifik dari Dio agar pesan error lebih mudah dibaca di UI
      final errorMessage =
          e.response?.data['message'] ?? 'Gagal terhubung ke server GymFit';
      throw Exception(errorMessage);
    } catch (e) {
      // Melempar kembali error tak terduga lainnya
      rethrow;
    }
  }
}
