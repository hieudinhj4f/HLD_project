// data/repository/pharmacy_repository_impl.dart
import 'package:hld_project/feature/Pharmacy/data/datasource/pharmacy_remote_datasource.dart';
import 'package:hld_project/feature/Pharmacy/data/model/pharmacy_model.dart'; // ← CẦN TẠO NẾU CHƯA CÓ
import 'package:hld_project/feature/Pharmacy/domain/entity/pharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/kpi_stats.dart';
import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

import '../model/kip_stat_model.dart';

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
}