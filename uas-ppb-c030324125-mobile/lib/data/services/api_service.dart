import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  // Menggunakan Pola Singleton agar instance Dio tidak dibuat berulang-ulang di memori
  ApiService._internal() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Solusi cerdas: status kode 4xx (termasuk 422 validasi) tidak dianggap crash oleh Dio
    _dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final String? token = prefs.getString('access_token');
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Sederhana dulu, nanti akan diisi fungsi hapus token & redirect ke login
          }
          return handler.next(e);
        },
      ),
    );
  }

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio = Dio();
  Dio get dio => _dio;
}