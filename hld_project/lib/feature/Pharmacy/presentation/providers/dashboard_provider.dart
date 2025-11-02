// presentation/providers/dashboard_provider.dart
import 'package:flutter/material.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/getAllPharmacy.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/pharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/kpi_stats.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/get_dashboard_stats.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/get_vendor_activity.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/get_pharmacy_by_id.dart';

class DashboardProvider with ChangeNotifier {
  // === DI: Usecase & AuthProvider ===
  final AuthProvider? _authProvider;
  final GetDashboardStats _getDashboardStats;
  final GetVendorActivity _getVendorActivity;
  final GetPharmacyById _getPharmacyInfo;
  final GetAllPharmacy _getAllPharmacies; // ĐÃ SỬA TÊN

  DashboardProvider({
    required AuthProvider? authProvider,
    required GetDashboardStats getDashboardStats,
    required GetVendorActivity getVendorActivity,
    required GetPharmacyById getPharmacyInfo,
    required GetAllPharmacy getAllPharmacies, // ĐÃ SỬA
  })  : _authProvider = authProvider,
        _getDashboardStats = getDashboardStats,
        _getVendorActivity = getVendorActivity,
        _getPharmacyInfo = getPharmacyInfo,
        _getAllPharmacies = getAllPharmacies;

  // === State ===
  bool _isLoading = false;
  String? _error;
  KpiStats _stats = KpiStats.zero(); // ĐÃ SỬA: DÙNG ZERO
  List<double> _chartData = List.filled(7, 0.0); // ĐÃ SỬA: 7 NGÀY
  Pharmacy? _pharmacy;

  // Dropdown
  bool _isListLoading = false;
  List<Pharmacy> _allAdminPharmacies = [];
  String? _selectedPharmacyId;

  // === Getters ===
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;
  KpiStats get stats => _stats;
  List<double> get chartData => _chartData;
  Pharmacy? get pharmacy => _pharmacy;
  bool get isListLoading => _isListLoading;
  List<Pharmacy> get allAdminPharmacies => _allAdminPharmacies;
  String? get selectedPharmacyId => _selectedPharmacyId;

  // === INITIAL LOAD ===
  Future<void> fetchInitialData() async {
    if (_isListLoading) return;

    _isListLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allAdminPharmacies = await _getAllPharmacies(); // ĐÃ SỬA

      if (_allAdminPharmacies.isNotEmpty) {
        _selectedPharmacyId = _allAdminPharmacies.first.id;
        await _loadDataForSelectedPharmacy();
      } else {
        reset();
      }
    } catch (e) {
      _error = "Lỗi tải danh sách nhà thuốc: $e";
      debugPrint('DashboardProvider Error: $e');
    } finally {
      _isListLoading = false;
      notifyListeners();
    }
  }

  // === SELECT PHARMACY ===
  Future<void> selectPharmacy(String newId) async {
    if (newId == _selectedPharmacyId) return;

    _selectedPharmacyId = newId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _loadDataForSelectedPharmacy();
  }

  // === REFRESH ===
  Future<void> refreshDataForSelectedPharmacy() async {
    if (_selectedPharmacyId == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _loadDataForSelectedPharmacy();
  }

  // === LOAD DATA FOR PHARMACY ===
  Future<void> _loadDataForSelectedPharmacy() async {
    if (_selectedPharmacyId == null) {
      _error = 'Chưa chọn nhà thuốc';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final results = await Future.wait([
        _getDashboardStats(_selectedPharmacyId!),
        _getVendorActivity(_selectedPharmacyId!),
        _getPharmacyInfo(_selectedPharmacyId!),
      ], eagerError: true);

      _stats = results[0] as KpiStats;
      _chartData = List<double>.from(results[1] as List); // AN TOÀN CAST
      _pharmacy = results[2] as Pharmacy?;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Load Data Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === RESET ON LOGOUT ===
  void reset() {
    _stats = KpiStats.zero();
    _chartData = List.filled(7, 0.0);
    _pharmacy = null;
    _error = null;
    _isLoading = false;
    _isListLoading = false;
    _allAdminPharmacies = [];
    _selectedPharmacyId = null;
    notifyListeners();
  }

  // === UPDATE AUTH (khi login/logout) ===
  void updateAuth(AuthProvider? auth) {
    if (auth == null) {
      reset();
    }
  }
}