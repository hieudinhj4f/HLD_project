import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

import '../entity/pharmacy.dart';

// domain/usecase/update_pharmacy.dart
import '../entity/pharmacy.dart';
import '../repository/pharmacy_repository.dart';

class UpdatePharmacy {
  final PharmacyRepository repository;

  const UpdatePharmacy(this.repository);

  Future<void> call(Pharmacy pharmacy) {
    return repository.updatePharmacy(pharmacy);
  }
}