import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/kpi_stats.dart';

class KpiStatsModel extends KpiStats {
  KpiStatsModel({
    required super.totalSold,
    required super.todayRevenue,
    required super.todayRevenuePercent,
    required super.totalRevenue,
    required super.totalRevenuePercent,
    super.totalProducts = 0, // ← MẶC ĐỊNH 0, SẼ GHI ĐÈ SAU
  });

  factory KpiStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return KpiStatsModel(
      // BỎ totalProducts → KHÔNG LẤY TỪ stats/daily
      totalSold: (data['totalSold'] as num?)?.toInt() ?? 0,
      todayRevenue: (data['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      todayRevenuePercent: (data['todayRevenuePercent'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalRevenuePercent: (data['totalRevenuePercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  KpiStats toEntity() {
    return KpiStats(
      totalProducts: totalProducts, // ← SẼ ĐƯỢC GHI ĐÈ BỞI GetTotalProductsUseCase
      totalSold: totalSold,
      todayRevenue: todayRevenue,
      todayRevenuePercent: todayRevenuePercent,
      totalRevenue: totalRevenue,
      totalRevenuePercent: totalRevenuePercent,
    );
  }

  factory KpiStatsModel.zero() {
    return KpiStatsModel(
      totalProducts: 0,
      totalSold: 0,
      todayRevenue: 0.0,
      todayRevenuePercent: 0.0,
      totalRevenue: 0.0,
      totalRevenuePercent: 0.0,
    );
  }
}