// data/repository/pharmacy_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hld_project/feature/Pharmacy/data/datasource/pharmacy_remote_datasource.dart';
import 'package:hld_project/feature/Pharmacy/data/model/pharmacy_model.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/pharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/kpi_stats.dart';
import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  final PharmacyRemoteDataSource remoteDatasource;

  PharmacyRepositoryImpl(this.remoteDatasource);

  // === CRUD PHARMACY ===
  @override
  Future<void> createPharmacy(Pharmacy pharmacy) async {
    final model = PharmacyModel.fromEntity(pharmacy);
    await remoteDatasource.add(model);
  }

  @override
  Future<void> updatePharmacy(Pharmacy pharmacy) async {
    final model = PharmacyModel.fromEntity(pharmacy);
    await remoteDatasource.update(model);
  }

  @override
  Future<void> deletePharmacy(String id) async {
    await remoteDatasource.delete(id);
  }

  @override
  Future<Pharmacy?> getPharmacyById(String id) async {
    final model = await remoteDatasource.getPharmacyById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Pharmacy>> getAllPharmacies() async {
    final models = await remoteDatasource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  // === DASHBOARD STATS ===
  @override
  Future<KpiStats> getDashboardStats(String pharmacyId) async {
    final model = await remoteDatasource.getDashboardStats(pharmacyId);
    return model.toEntity();
  }

  @override
  Future<List<double>> getVendorActivity(String pharmacyId) async {
    return await remoteDatasource.getVendorActivity(pharmacyId);
  }

  // === GLOBAL STATS (CHO ADMIN) ===
  @override
  Future<List<String>> getAllPharmacyIds() async {
    return await remoteDatasource.getAllPharmacyIds();
  }

  @override
  Future<KpiStats> getKpiStatsForPharmacy(String pharmacyId) async {
    final model = await remoteDatasource.getKpiStatsForPharmacy(pharmacyId);
    return model.toEntity();
  }

  // === PURCHASE PRODUCT (CẬP NHẬT DOANH THU + SỐ LƯỢNG) ===
  @override
  Future<void> purchaseProduct({
    required String productId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      throw Exception("Số lượng mua phải lớn hơn 0");
    }

    final firestore = FirebaseFirestore.instance;
    final productRef = firestore.collection('product').doc(productId);

    // Lấy pharmacyId từ product
    final productDoc = await productRef.get();
    if (!productDoc.exists) {
      throw Exception("Sản phẩm không tồn tại");
    }

    final pharmacyId = productDoc.data()?['pharmacyId'] as String?;
    if (pharmacyId == null || pharmacyId.isEmpty) {
      throw Exception("Sản phẩm không liên kết với nhà thuốc");
    }

    final statsRef = firestore
        .collection('pharmacy')
        .doc(pharmacyId)
        .collection('stats')
        .doc('daily');

    // Dùng Transaction để đảm bảo đồng bộ
    await firestore.runTransaction((transaction) async {
      // 1. Đọc product
      final productSnapshot = await transaction.get(productRef);
      if (!productSnapshot.exists) {
        throw Exception("Sản phẩm không tồn tại trong transaction");
      }

      final productData = productSnapshot.data()!;
      final currentQuantity = productData['quantity'] as int? ?? 0;
      final price = (productData['price'] as num?)?.toDouble() ?? 0.0;

      if (currentQuantity < quantity) {
        throw Exception("Không đủ hàng tồn kho");
      }

      // 2. Đọc stats/daily
      final statsSnapshot = await transaction.get(statsRef);
      final statsData = statsSnapshot.exists ? statsSnapshot.data()! : {};

      final currentItemsSold = (statsData['itemsSold'] as num?)?.toInt() ?? 0;
      final currentTodayRevenue = (statsData['todayRevenue'] as num?)?.toDouble() ?? 0.0;
      final currentTotalRevenue = (statsData['totalRevenue'] as num?)?.toDouble() ?? 0.0;

      // 3. Tính toán
      final revenueAdded = price * quantity;
      final newQuantity = currentQuantity - quantity;
      final newItemsSold = currentItemsSold + quantity;
      final newTodayRevenue = currentTodayRevenue + revenueAdded;
      final newTotalRevenue = currentTotalRevenue + revenueAdded;

      // 4. Cập nhật
      transaction.update(productRef, {
        'quantity': newQuantity,
      });

      transaction.set(
        statsRef,
        {
          'itemsSold': newItemsSold,
          'todayRevenue': newTodayRevenue,
          'totalRevenue': newTotalRevenue,
          // Các field khác (nếu cần cập nhật %)
          'todayRevenuePercent': 0.0, // sẽ tính lại sau
          'totalRevenuePercent': 0.0,
        },
        SetOptions(merge: true),
      );
    });
  }

  @override
  Future<int> getTotalProducts(String pharmacyId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('product')
        .where('pharmacyId', isEqualTo: pharmacyId)
        .get();

    int total = 0;
    for (final doc in snapshot.docs) {
      final qty = doc.data()['quantity'] as int? ?? 0;
      total += qty;
    }

    return total;
  }

  // === UPDATE REVENUE FROM ORDER (CALLED AFTER ORDER IS COMPLETE) ===
  @override
  Future<void> updateOrderRevenue({
    required String pharmacyId,
    required double totalAmount,
    required int itemsSold,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final statsRef = firestore
        .collection('pharmacy')
        .doc(pharmacyId)
        .collection('stats')
        .doc('daily');

    // Use transaction to ensure atomicity
    await firestore.runTransaction((transaction) async {
      final statsSnapshot = await transaction.get(statsRef);
      final statsData = statsSnapshot.exists ? statsSnapshot.data()! : {};

      final currentItemsSold = (statsData['itemsSold'] as num?)?.toInt() ?? 0;
      final currentTodayRevenue = (statsData['todayRevenue'] as num?)?.toDouble() ?? 0.0;
      final currentTotalRevenue = (statsData['totalRevenue'] as num?)?.toDouble() ?? 0.0;

      // Calculate new values
      final newItemsSold = currentItemsSold + itemsSold;
      final newTodayRevenue = currentTodayRevenue + totalAmount;
      final newTotalRevenue = currentTotalRevenue + totalAmount;

      // Update stats
      transaction.set(
        statsRef,
        {
          'itemsSold': newItemsSold,
          'todayRevenue': newTodayRevenue,
          'totalRevenue': newTotalRevenue,
          'todayRevenuePercent': 0.0,
          'totalRevenuePercent': 0.0,
        },
        SetOptions(merge: true),
      );
    });
  }
}