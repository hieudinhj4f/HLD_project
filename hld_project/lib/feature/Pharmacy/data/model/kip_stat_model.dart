import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/kpi_stats.dart';

// Model này dùng để đọc dữ liệu KPI thô từ Firestore
class KpiStatsModel extends KpiStats {
  KpiStatsModel({
    required super.totalProducts,
    required super.itemsSold,
    required super.todayRevenue,
    required super.todayRevenuePercent,
    required super.totalRevenue,
    required super.totalRevenuePercent,
  });

  factory KpiStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KpiStatsModel(
      totalProducts: (data['totalProducts'] as num?)?.toInt() ?? 0,
      itemsSold: (data['itemsSold'] as num?)?.toInt() ?? 0,
      todayRevenue: (data['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      todayRevenuePercent: (data['todayRevenuePercent'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalRevenuePercent: (data['totalRevenuePercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Chuyển Model (thô) -> Entity (sạch)
  KpiStats toEntity() {
    return KpiStats(
      totalProducts: totalProducts,
      itemsSold: itemsSold,
      todayRevenue: todayRevenue,
      todayRevenuePercent: todayRevenuePercent,
      totalRevenue: totalRevenue,
      totalRevenuePercent: totalRevenuePercent,
    );
  }
}