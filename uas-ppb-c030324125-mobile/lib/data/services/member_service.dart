import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/member_model.dart';

class MemberService {
  final Dio _dio = ApiService().dio;

  /// 1. Ambil Semua Data Member (GET) - KEMBALI KE STRUKTUR ASLI
  Future<Map<String, dynamic>> getMembers({String search = ''}) async {
    try {
      final response = await _dio.get(
        '/members',
        queryParameters: {if (search.isNotEmpty) 'search': search},
      );

      if (response.statusCode == 200) {
        List<dynamic> membersRaw;

        // 🌟 AMAN: Cek tipe data respons dari Laravel secara dinamis
        if (response.data is List) {
          membersRaw = response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          membersRaw = response.data['data'];
        } else {
          membersRaw = [];
        }

        List<MemberModel> members = membersRaw
            .map((jsonItem) => MemberModel.fromJson(jsonItem))
            .toList();

        return {'success': true, 'data': members};
      }
      return {'success': false, 'message': 'Gagal mengambil data member.'};
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Terjadi kesalahan jaringan';
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan sistem: $e'};
    }
  }

  /// 2. Kirim Data Member Baru (POST)
  Future<Map<String, dynamic>> createMember(MemberModel member) async {
    try {
      final response = await _dio.post('/members', data: member.toCreateJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final MemberModel newMember = MemberModel.fromJson(
          response.data['data'],
        );
        return {'success': true, 'data': newMember};
      }

      // ANTISIPASI 1: Jika ApiService dikonfigurasi untuk tidak melempar throw pada status 422
      if (response.statusCode == 422) {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Data yang dikirim tidak valid.',
          'errors': response
              .data['errors'], // Meneruskan map error validasi ke Provider
        };
      }

      return {
        'success': false,
        'message': response.data?['message'] ?? 'Gagal menambah data member.',
      };
    } on DioException catch (e) {
      // ANTISIPASI 2: Jika Dio melempar exception normal saat mendeteksi status 422
      if (e.response?.statusCode == 422) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Data yang dikirim tidak valid.',
          'errors':
              e.response?.data['errors'], // Kirimkan detail error per kolom
        };
      }
      final errorMessage =
          e.response?.data['message'] ?? 'Gagal menambah data member';
      return {'success': false, 'message': errorMessage, 'errors': null};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan sistem: $e'};
    }
  }

  /// 3. Perbarui Data Member Lama (PUT)
  Future<Map<String, dynamic>> updateMember(
    int id,
    MemberModel updatedMember,
  ) async {
    try {
      final response = await _dio.put(
        '/members/$id',
        data: updatedMember.toJson(),
      );

      if (response.statusCode == 200) {
        final MemberModel memberResult = MemberModel.fromJson(
          response.data['data'],
        );
        return {'success': true, 'data': memberResult};
      }
      return {'success': false, 'message': 'Gagal memperbarui data member.'};
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Gagal memperbarui data member';
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan sistem: $e'};
    }
  }

  /// 4. Hapus Data Member dari Database (DELETE)
  Future<Map<String, dynamic>> deleteMember(int id) async {
    try {
      final response = await _dio.delete('/members/$id');

      if (response.statusCode == 200) {
        return {'success': true};
      }
      return {
        'success': false,
        'message': 'Gagal menghapus member dari server.',
      };
    } on DioException catch (e) {
      // Jika Laravel mengembalikan 404 karena data tidak ditemukan
      if (e.response?.statusCode == 404) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ??
              'Data member tidak ditemukan di server.',
        };
      }
      final errorMessage =
          e.response?.data['message'] ?? 'Gagal menghapus member';
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan sistem: $e'};
    }
  }
}
