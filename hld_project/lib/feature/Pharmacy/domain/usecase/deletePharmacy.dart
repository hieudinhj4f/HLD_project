import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

import '../entity/pharmacy.dart';

class deletePharmacy {
  final PharmacyRepository p;
  deletePharmacy(this.p);

  Future<void> call(String id) async => await p.deletePharmacy(id);
}