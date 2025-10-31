import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

import '../entity/pharmacy.dart';

class getAllPharmacy{
  final PharmacyRepository p;
  getAllPharmacy(this.p);

  Future<List<Pharmacy>> call()  async => await p.getAllProducts();
}