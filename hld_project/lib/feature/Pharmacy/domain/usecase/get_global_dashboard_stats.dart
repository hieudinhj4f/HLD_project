// domain/usecase/get_global_dashboard_stats.dart
import '../entity/kpi_stats.dart';
import '../repository/pharmacy_repository.dart';
// domain/usecase/get_global_dashboard_stats.dart

class GetGlobalDashboardStats {
  final PharmacyRepository repository;
  const GetGlobalDashboardStats(this.repository);

  Future<KpiStats> call() async {
    final ids = await repository.getAllPharmacyIds();
    if (ids.isEmpty) return KpiStats.zero();

    int totalProducts = 0;
    int totalSold = 0;
    double todayRevenue = 0;
    double totalRevenue = 0;

    for (final id in ids) {
      final stats = await repository.getKpiStatsForPharmacy(id);
      totalProducts += stats.totalProducts;
      totalSold += stats.totalSold;
      todayRevenue += stats.todayRevenue;
      totalRevenue += stats.totalRevenue;
    }

    return KpiStats(
      totalProducts: totalProducts,
      totalSold: totalSold,
      todayRevenue: todayRevenue,
      totalRevenue: totalRevenue,
      todayRevenuePercent: 0.0,
      totalRevenuePercent: 0.0,
    );
  }
}