import 'package:flutter/material.dart';
import '../data/services/dashboard_service.dart';
import '../data/models/member_model.dart';

class DashboardProvider with ChangeNotifier {
  // Menggunakan service yang sudah terkonfigurasi secara terpusat
  final DashboardService _dashboardService = DashboardService();

  int _totalMember = 0;
  int _memberBaruBulanIni = 0;
  List<MemberModel> _memberTerbaru = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getter
  int get totalMember => _totalMember;
  int get memberBaruBulanIni => _memberBaruBulanIni;
  List<MemberModel> get memberTerbaru => _memberTerbaru;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _dashboardService.getDashboardData();
      if (result['success'] == true) {
        final data = result['data'];
        _totalMember = data['total_member'];
        _memberBaruBulanIni = data['member_baru_bulan_ini'];

        // Memetakan list JSON 5 member terbaru ke dalam objek model
        _memberTerbaru = (data['member_terbaru'] as List)
            .map((item) => MemberModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
