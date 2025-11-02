import 'package:hld_project/feature/Pharmacy/domain/usecase/createPharmacy.dart';

import '../entity/pharmacy.dart';
abstract class PharmacyRepository {
  Future<List<Pharmacy>> GetAllPharmacy();

  Future<void> createPharmacy(Pharmacy p);

  Future<void> updatePharmacy(Pharmacy p);

  Future<void> deletePharmacy(String id);

  Future<Pharmacy?> getPharmacyById(String id);
}