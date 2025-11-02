import 'package:hld_project/feature/Pharmacy/domain/entity/pharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

class GetPharmacyById {
  final PharmacyRepository repository;

  GetPharmacyById(this.repository);

  // Usecase này nhận 1 'id' và trả về 'Pharmacy' (hoặc null)
  Future<Pharmacy?> call(String id) async {
    return await repository.getPharmacyById(id);
  }
}