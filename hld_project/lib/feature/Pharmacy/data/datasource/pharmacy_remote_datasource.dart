import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/firebase_remote_datasource.dart';
import '../model/kip_stat_model.dart';
import '../model/pharmacy_model.dart';

abstract class PharmacyRemoteDataSource {
  Future<List<PharmacyModel>> getAll(); // Admin: lấy tất cả nhà thuốc
  Future<PharmacyModel?> getPharmacyById(String id); // Theo ID cụ thể
  Future<PharmacyModel?> getPharmacyByAuth(String pharmacyId); // Theo người đăng nhập

  Future<void> add(PharmacyModel pharmacy);
  Future<void> update(PharmacyModel pharmacy);
  Future<void> delete(String id);

  // Dashboard (cho 1 nhà thuốc)
  Future<KpiStatsModel> getDashboardStats(String pharmacyId);
  Future<List<double>> getVendorActivity(String pharmacyId);

  // Global (cho Admin)
  Future<List<String>> getAllPharmacyIds();
  Future<KpiStatsModel> getKpiStatsForPharmacy(String pharmacyId);
}

class PharmacyRemoteDataSourceImpl implements PharmacyRemoteDataSource {
  final FirebaseRemoteDS<PharmacyModel> _remoteSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PharmacyRemoteDataSourceImpl()
      : _remoteSource = FirebaseRemoteDS<PharmacyModel>(
    collectionName: 'pharmacy',
    fromFirestore: (doc) => PharmacyModel.fromFirestore(doc),
    toFirestore: (model) => model.toJson(),
  );

  // === CRUD PHARMACY ===
  @override
  Future<List<PharmacyModel>> getAll() async {
    // Admin dùng: lấy tất cả nhà thuốc
    return await _remoteSource.getAll();
  }

  @override
  Future<PharmacyModel?> getPharmacyById(String id) async {
    return await _remoteSource.getById(id);
  }

  @override
  Future<PharmacyModel?> getPharmacyByAuth(String pharmacyId) async {
    // Chỉ lấy nhà thuốc hiện tại (ví dụ khi người bán login)
    final doc = await _firestore.collection('pharmacy').doc(pharmacyId).get();
    if (!doc.exists) return null;
    return PharmacyModel.fromFirestore(doc);
  }

  @override
  Future<void> add(PharmacyModel pharmacy) async {
    await _remoteSource.add(pharmacy);
  }

  @override
  Future<void> update(PharmacyModel pharmacy) async {
    await _remoteSource.update(pharmacy.id, pharmacy);
  }

  @override
  Future<void> delete(String id) async {
    await _remoteSource.delete(id);
  }

  // === DASHBOARD DATA ===
  @override
  Future<KpiStatsModel> getDashboardStats(String pharmacyId) async {
    try {
      final doc = await _firestore
          .collection('pharmacy')
          .doc(pharmacyId)
          .collection('stats')
          .doc('daily')
          .get();

      if (!doc.exists) {
        return KpiStatsModel(
          totalProducts: 0,
          totalSold: 0,
          todayRevenue: 0.0,
          todayRevenuePercent: 0.0,
          totalRevenue: 0.0,
          totalRevenuePercent: 0.0,
        );
      }

      return KpiStatsModel.fromFirestore(doc);
    } catch (e) {
      print("🔥 Error in getDashboardStats($pharmacyId): $e");
      return KpiStatsModel.zero();
    }
  }

  @override
  Future<List<double>> getVendorActivity(String pharmacyId) async {
    try {
      final doc = await _firestore
          .collection('pharmacy')
          .doc(pharmacyId)
          .collection('stats')
          .doc('activity_week')
          .get();

      if (!doc.exists || !doc.data()!.containsKey('last7days')) {
        return List.filled(7, 0.0);
      }

      final data = doc.data()!;
      final rawList = data['last7days'] as List<dynamic>? ?? [];
      final result = List<double>.filled(7, 0.0);

      for (int i = 0; i < rawList.length && i < 7; i++) {
        final value = rawList[i];
        if (value is num) result[i] = value.toDouble();
      }

      return result;
    } catch (e) {
      print("🔥 Error in getVendorActivity($pharmacyId): $e");
      return List.filled(7, 0.0);
    }
  }

  // === GLOBAL ADMIN DASHBOARD ===
  @override
  Future<List<String>> getAllPharmacyIds() async {
    final snapshot = await _firestore.collection('pharmacy').get();
    final ids = snapshot.docs.map((doc) => doc.id).toList();
    print("✅ PHARMACY IDS: $ids");
    return ids;
  }

  @override
  Future<KpiStatsModel> getKpiStatsForPharmacy(String pharmacyId) async {
    try {
      final doc = await _firestore
          .collection('pharmacy')
          .doc(pharmacyId)
          .collection('stats')
          .doc('daily')
          .get();

      if (!doc.exists) {
        return KpiStatsModel.zero();
      }

      return KpiStatsModel.fromFirestore(doc);
    } catch (e) {
      print("🔥 Error in getKpiStatsForPharmacy($pharmacyId): $e");
      return KpiStatsModel.zero();
    }
  }
}
