import 'package:flutter/material.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/pharmacy.dart';
import '../../domain/entity/kpi_stats.dart';
import '../../domain/usecase/get_dashboard_stats.dart';
import '../../domain/usecase/get_vendor_activity.dart';
import '../../domain/usecase/get_pharmacy_by_id.dart';

class DashboardProvider with ChangeNotifier {
  // === DI: Usecase & AuthProvider ===
  AuthProvider? _authProvider;
  final GetDashboardStats _getDashboardStats;
  final GetVendorActivity _getVendorActivity;
  final GetPharmacyById _getPharmacyInfo;

  DashboardProvider({
    AuthProvider? authProvider,
    required GetDashboardStats getDashboardStats,
    required GetVendorActivity getVendorActivity,
    required GetPharmacyById getPharmacyInfo,
  })  : _authProvider = authProvider,
        _getDashboardStats = getDashboardStats,
        _getVendorActivity = getVendorActivity,
        _getPharmacyInfo = getPharmacyInfo {
    // Tự động load nếu đã login + có pharmacyId
    if (_authProvider?.isLoggedIn == true && _authProvider?.user?.pharmacyId != null) {
      fetchDashboardData();
    }
  }

  // === State ===
  bool _isLoading = false;
  String? _error;
  KpiStats _stats = KpiStats();
  List<double> _chartData = List.filled(6, 0.0);
  Pharmacy? _pharmacy;

  // === Getters ===
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;
  KpiStats get stats => _stats;
  List<double> get chartData => _chartData;
  Pharmacy? get pharmacy => _pharmacy;

  // === Cập nhật Auth (Thông minh hơn) ===
  void updateAuth(AuthProvider newAuth) {
    final bool wasLoggedIn = _authProvider?.isLoggedIn ?? false;
    final String? oldPharmacyId = _authProvider?.user?.pharmacyId;

    _authProvider = newAuth;

    final bool isNowLoggedIn = newAuth.isLoggedIn;
    final String? newPharmacyId = newAuth.user?.pharmacyId;

    // Chỉ reload nếu:
    // - Đăng nhập lần đầu
    // - Đổi pharmacyId
    if (isNowLoggedIn && newPharmacyId != null) {
      if (!wasLoggedIn || oldPharmacyId != newPharmacyId) {
        fetchDashboardData();
      }
    } else {
      // Reset nếu logout
      if (!isNowLoggedIn) {
        _reset();
      }
    }

    notifyListeners();
  }

  // === Load dữ liệu ===
  Future<void> fetchDashboardData() async {
    final String? pharmacyId = _authProvider?.user?.pharmacyId;

    if (pharmacyId == null) {
      _error = 'Không tìm thấy Pharmacy ID';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_isLoading) return; // Tránh gọi 2 lần

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _getDashboardStats(pharmacyId),
        _getVendorActivity(pharmacyId),
        _getPharmacyInfo(pharmacyId),
      ], eagerError: true);

      _stats = results[0] as KpiStats;
      _chartData = (results[1] as List<dynamic>).cast<double>();
      _pharmacy = results[2] as Pharmacy?;
    } catch (e) {
      _error = e.toString();
      print('DashboardProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === Refresh (kéo xuống làm mới) ===
  Future<void> refresh() => fetchDashboardData();

  // === Reset (logout) ===
  void _reset() {
    _stats = KpiStats();
    _chartData = List.filled(6, 0.0);
    _pharmacy = null;
    _error = null;
    _isLoading = false;
  }
}