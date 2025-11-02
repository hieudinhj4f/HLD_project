class KpiStats {
  final int totalProducts;
  final int itemsSold;
  final double todayRevenue;
  final double todayRevenuePercent;
  final double totalRevenue;
  final double totalRevenuePercent;

  KpiStats({
    this.totalProducts = 0,
    this.itemsSold = 0,
    this.todayRevenue = 0.0,
    this.todayRevenuePercent = 0.0,
    this.totalRevenue = 0.0,
    this.totalRevenuePercent = 0.0,
  });
}