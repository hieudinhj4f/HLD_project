// presentation/providers/dashboard_provider.dart
import 'package:flutter/material.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/getAllPharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/get_global_dashboard_stats.dart';
import 'package:hld_project/feature/Product/domain/usecase/get_total_sold.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/pharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/kpi_stats.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/get_vendor_activity.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/get_pharmacy_by_id.dart';
import 'package:hld_project/feature/Product/domain/usecase/get_total_sold.dart';

import '../../domain/usecase/get_total_products.dart'; // ĐÃ SỬA

class DashboardProvider with ChangeNotifier {
  // === DI: Usecase & AuthProvider ===


  final AuthProvider? _authProvider;
  final GetGlobalDashboardStats _getDashboardStats;
  final GetVendorActivity _getVendorActivity;
  final GetPharmacyById _getPharmacyInfo;
  final GetAllPharmacy _getAllPharmacies;
  final GetTotalProductsUseCase _getTotalProducts;
  final getTotalSold _getTotalSold;

  DashboardProvider({
    required AuthProvider? authProvider,
    required GetGlobalDashboardStats getDashboardStats,
    required GetVendorActivity getVendorActivity,
    required GetPharmacyById getPharmacyInfo,
    required GetAllPharmacy getAllPharmacies,
    required GetTotalProductsUseCase getTotalProducts,
    required getTotalSold getTotalSold,
  })  : _authProvider = authProvider,
        _getDashboardStats = getDashboardStats,
        _getVendorActivity = getVendorActivity,
        _getPharmacyInfo = getPharmacyInfo,
        _getAllPharmacies = getAllPharmacies,
        _getTotalProducts = getTotalProducts,
        _getTotalSold = getTotalSold;
  // === State ===
  bool _isLoading = false;
  String? _error;
  KpiStats _stats = KpiStats.zero();
  List<double> _chartData = List.filled(7, 0.0);
  Pharmacy? _pharmacy;
  int _totalSold = 0;

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
  int get totalSold => _totalSold; // THÊM GETTER

  // === INITIAL LOAD ===
  Future<void> fetchInitialData() async {
    if (_isListLoading) return;

    _isListLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allAdminPharmacies = await _getAllPharmacies();

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
        _getDashboardStats(),
        _getVendorActivity(_selectedPharmacyId!),
        _getPharmacyInfo(_selectedPharmacyId!),
        _getTotalProducts(_selectedPharmacyId!),
        _getTotalSold(_selectedPharmacyId!), // THÊM: TỔNG SOLD
      ], eagerError: true);

      final baseStats = results[0] as KpiStats;
      final chartData = results[1] as List<double>;
      final pharmacy = results[2] as Pharmacy?;
      final totalProducts = results[3] as int;
      final totalSold = results[4] as int; // LẤY TỔNG SOLD

      _stats = baseStats.copyWith(totalProducts: totalProducts);
      _chartData = List<double>.from(chartData);
      _pharmacy = pharmacy;
      _totalSold = totalSold; // GÁN VÀO STATE
      _error = null;
    } catch (e) {
      _error = "Lỗi tải dữ liệu: $e";
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
    _totalSold = 0; // RESET SOLD
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