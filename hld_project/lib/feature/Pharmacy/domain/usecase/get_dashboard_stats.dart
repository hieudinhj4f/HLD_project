import 'package:hld_project/feature/Pharmacy/domain/entity/kpi_stats.dart';
import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

class GetDashboardStats {
  final PharmacyRepository repository;

  GetDashboardStats(this.repository);

  // Lấy KpiStats dựa trên ID nhà thuốc
  Future<KpiStats> call(String pharmacyId) async {
    // (Logic: Gọi repository để lấy stats.
    // Repository sẽ chịu trách nhiệm gọi Cloud Function hoặc 1 doc)
    return await repository.getDashboardStats(pharmacyId);
  }
}