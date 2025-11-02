import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

import '../entity/pharmacy.dart';

// domain/usecase/create_pharmacy.dart
import '../entity/pharmacy.dart';
import '../repository/pharmacy_repository.dart';

class CreatePharmacy {
  final PharmacyRepository repository;

  const CreatePharmacy(this.repository);

  Future<void> call(Pharmacy pharmacy) {
    return repository.createPharmacy(pharmacy);
  }
}