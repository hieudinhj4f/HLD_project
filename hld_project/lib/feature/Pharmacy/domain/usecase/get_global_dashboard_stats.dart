// domain/usecase/get_global_dashboard_stats.dart
import '../entity/kpi_stats.dart';
import '../repository/pharmacy_repository.dart';

class GetGlobalDashboardStats {
  final PharmacyRepository repository;
  const GetGlobalDashboardStats(this.repository);

  Future<KpiStats> call() async {
    final ids = await repository.getAllPharmacyIds();

    int totalProducts = 0;
    int itemsSold = 0;
    double todayRevenue = 0;
    double totalRevenue = 0;

    for (final id in ids) {
      final stats = await repository.getKpiStatsForPharmacy(id);
      totalProducts += stats.totalProducts;
      itemsSold += stats.itemsSold;
      todayRevenue += stats.todayRevenue;
      totalRevenue += stats.totalRevenue;
    }

    return KpiStats(
      totalProducts: totalProducts,
      itemsSold: itemsSold,
      todayRevenue: todayRevenue,
      totalRevenue: totalRevenue,
      todayRevenuePercent: 0.0,
      totalRevenuePercent: 0.0,
    );
  }
}