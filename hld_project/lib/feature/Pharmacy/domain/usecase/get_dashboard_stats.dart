// domain/usecase/get_dashboard_stats.dart
import '../entity/kpi_stats.dart';
import '../repository/pharmacy_repository.dart';

class GetDashboardStats {
  final PharmacyRepository repository;
  
  GetDashboardStats(this.repository);

  Future<KpiStats> call(String pharmacyId) async {
    return await repository.getDashboardStats(pharmacyId);
  }
}





