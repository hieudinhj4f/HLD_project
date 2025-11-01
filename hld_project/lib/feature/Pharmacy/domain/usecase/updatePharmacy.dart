import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

import '../entity/pharmacy.dart';

class UpdatePharmacy {
  final PharmacyRepository p;
  UpdatePharmacy(this.p);

  Future<void> call(Pharmacy pharma) async => await p.updatePharmacy(pharma);
}