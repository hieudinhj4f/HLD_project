import '../repository/pharmacy_repository.dart';

class PurchaseProductUseCase {
  final PharmacyRepository pharmacyRepository;

  PurchaseProductUseCase(this.pharmacyRepository);

  Future<void> call({
    required String productId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      throw Exception("Số lượng mua phải lớn hơn 0");
    }
    await pharmacyRepository.purchaseProduct(
      productId: productId,
      quantity: quantity,
    );
  }
}