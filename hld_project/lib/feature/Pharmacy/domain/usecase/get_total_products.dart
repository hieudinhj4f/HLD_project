// lib/feature/Pharmacy/domain/usecases/get_total_products.dart
import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

class GetTotalProductsUseCase {
  final PharmacyRepository repository;

  GetTotalProductsUseCase(this.repository);

  Future<int> call(String pharmacyId) async {
    return await repository.getTotalProducts(pharmacyId);
  }
}