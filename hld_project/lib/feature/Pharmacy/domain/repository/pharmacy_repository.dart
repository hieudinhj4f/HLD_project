// feature/Pharmacy/domain/repository/pharmacy_repository.dart

import 'package:hld_project/feature/Pharmacy/domain/entity/pharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/kpi_stats.dart';

abstract class PharmacyRepository {
  // === CRUD PHARMACY ===
  Future<void> createPharmacy(Pharmacy pharmacy);
  Future<void> updatePharmacy(Pharmacy pharmacy);
  Future<void> deletePharmacy(String id);
  Future<Pharmacy?> getPharmacyById(String id);
  Future<List<Pharmacy>> getAllPharmacies(); // ĐÃ SỬA TÊN

  // === DASHBOARD (CHO 1 PHARMACY) ===
  Future<KpiStats> getDashboardStats(String pharmacyId);
  Future<List<double>> getVendorActivity(String pharmacyId);

  // === GLOBAL (CHO ADMIN) ===
  Future<List<String>> getAllPharmacyIds(); // THÊM
  Future<KpiStats> getKpiStatsForPharmacy(String pharmacyId);
  Future<void> purchaseProduct({
    required String productId,
    required int quantity,
  });
  Future<int> getTotalProducts(String pharmacyId);
  
  // === UPDATE REVENUE FROM ORDER ===
  Future<void> updateOrderRevenue({
    required String pharmacyId,
    required double totalAmount,
    required int itemsSold,
  });
}