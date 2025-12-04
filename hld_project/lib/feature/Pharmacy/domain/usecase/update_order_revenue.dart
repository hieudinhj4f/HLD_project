import '../repository/pharmacy_repository.dart';

class UpdateOrderRevenue {
  final PharmacyRepository repository;

  UpdateOrderRevenue(this.repository);

  Future<void> call({
    required String pharmacyId,
    required double totalAmount,
    required int itemsSold,
  }) async {
    await repository.updateOrderRevenue(
      pharmacyId: pharmacyId,
      totalAmount: totalAmount,
      itemsSold: itemsSold,
    );
  }
}

