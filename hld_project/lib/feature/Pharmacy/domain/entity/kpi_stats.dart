// lib/feature/Pharmacy/domain/entity/kpi_stats.dart
class KpiStats {
  final int totalProducts;
  final int totalSold;
  final double todayRevenue;
  final double todayRevenuePercent;
  final double totalRevenue;
  final double totalRevenuePercent;

  KpiStats({
    this.totalProducts = 0,
    this.totalSold = 0,
    this.todayRevenue = 0.0,
    this.todayRevenuePercent = 0.0,
    this.totalRevenue = 0.0,
    this.totalRevenuePercent = 0.0,
  });

  factory KpiStats.zero() => KpiStats();

  /// Tạo bản sao với các giá trị mới
  KpiStats copyWith({
    int? totalProducts,
    int? totalSold,
    double? todayRevenue,
    double? todayRevenuePercent,
    double? totalRevenue,
    double? totalRevenuePercent,
  }) {
    return KpiStats(
      totalProducts: totalProducts ?? this.totalProducts,
      totalSold: totalSold ?? this.totalSold,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      todayRevenuePercent: todayRevenuePercent ?? this.todayRevenuePercent,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalRevenuePercent: totalRevenuePercent ?? this.totalRevenuePercent,
    );
  }

  @override
  String toString() {
    return 'KpiStats(totalProducts: $totalProducts, itemsSold: $totalSold, todayRevenue: $todayRevenue)';
  }
}