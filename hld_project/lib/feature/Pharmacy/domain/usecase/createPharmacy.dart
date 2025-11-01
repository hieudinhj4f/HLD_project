import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

import '../entity/pharmacy.dart';

class CreatePharmacy{
  final PharmacyRepository p;
  CreatePharmacy(this.p);

  Future<void> call(Pharmacy pharma) async => await p.createPharmacy(pharma);
}