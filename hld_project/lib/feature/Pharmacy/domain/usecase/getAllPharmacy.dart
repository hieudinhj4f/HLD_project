import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

import '../entity/pharmacy.dart';

class GetAllPharmacy{
  final PharmacyRepository p;
  GetAllPharmacy(this.p);

  Future<List<Pharmacy>> call()  async => await p.getAllProducts();
}