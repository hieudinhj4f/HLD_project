import '../entity/product/product.dart';
import '../repository/product_repository.dart';

class getTotalSold {
  final ProductRepository productRepository;

  getTotalSold(this.productRepository);

  Future<void> call (String pharmacyId) async => await productRepository.getTotalSold(pharmacyId);
}
