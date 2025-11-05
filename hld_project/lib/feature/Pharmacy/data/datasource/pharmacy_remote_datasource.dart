import 'package:cloud_firestore/cloud_firestore.dart'; // <-- 1. THÊM IMPORT NÀY
import '../../../../core/data/firebase_remote_datasource.dart';
import '../model/kip_stat_model.dart';
import '../model/pharmacy_model.dart';

abstract class PharmacyRemoteDataSource {
  Future<List<PharmacyModel>> getAll();
  Future<PharmacyModel?> getPharmacyById(String id);
  Future<void> add(PharmacyModel pharmacy);
  Future<void> update(PharmacyModel pharmacy);
  Future<void> delete(String id);

  // Dashboard
  Future<KpiStatsModel> getDashboardStats(String pharmacyId);

  Future<List<double>> getVendorActivity(String pharmacyId);

  // Global
  Future<List<String>> getAllPharmacyIds();
  Future<KpiStatsModel> getKpiStatsForPharmacy(String pharmacyId);
}

class PharmacyRemoteDataSourceImpl implements PharmacyRemoteDataSource {
  // Generic helper cho PharmacyModel
  final FirebaseRemoteDS<PharmacyModel> _remoteSource;

  // Firestore instance cho custom queries
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
    return await _remoteSource.getAll();
  }

  @override
  Future<PharmacyModel?> getPharmacyById(String id) async {
    return await _remoteSource.getById(id);
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

  @override
  Future<KpiStatsModel> getDashboardStats(String pharmacyId) async {
    final doc = await _firestore
        .collection('pharmacy')
        .doc(pharmacyId)
        .collection('stats')
        .doc('daily')
        .get();

    if (!doc.exists) {
      return  KpiStatsModel(
        totalProducts: 0,
        itemsSold: 0,
        todayRevenue: 0.0,
        todayRevenuePercent: 0.0,
        totalRevenue: 0.0,
        totalRevenuePercent: 0.0,
      );
    }

    return KpiStatsModel.fromFirestore(doc);
  }

  @override
  Future<List<double>> getVendorActivity(String pharmacyId) async {
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

    // Tạo mảng 7 phần tử, mặc định 0.0
    final result = List<double>.filled(7, 0.0);

    // Gán dữ liệu thật (tối đa 7 phần tử)
    for (int i = 0; i < rawList.length && i < 7; i++) {
      final value = rawList[i];
      if (value is num) {
        result[i] = value.toDouble();
      }
    }

    return result;
  }

  // === GLOBAL STATS (CHO ADMIN) ===
  @override
  Future<List<String>> getAllPharmacyIds() async {
    final snapshot = await _firestore.collection('pharmacy').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  @override
  Future<KpiStatsModel> getKpiStatsForPharmacy(String pharmacyId) async {
    final doc = await _firestore
        .collection('pharmacy')
        .doc(pharmacyId)
        .collection('stats')
        .doc('daily')
        .get();

    if (!doc.exists) {
      return KpiStatsModel(
        totalProducts: 0,
        itemsSold: 0,
        todayRevenue: 0.0,
        todayRevenuePercent: 0.0,
        totalRevenue: 0.0,
        totalRevenuePercent: 0.0,
      );
    }

    return KpiStatsModel.fromFirestore(doc);
  }
}