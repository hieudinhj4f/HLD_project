import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

import '../entity/pharmacy.dart';

class updatePharmacy {
  final PharmacyRepository p;
  updatePharmacy(this.p);

  Future<void> call(Pharmacy pharma) async => await p.updatePharmacy(pharma);
}