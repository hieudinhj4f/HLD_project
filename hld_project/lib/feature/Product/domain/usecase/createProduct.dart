import '../entity/product/product.dart';
import '../repository/product_repository.dart';

class CreateProduct {
  final ProductRepository productRepository;

  CreateProduct(this.productRepository);

  Future<void> call (Product product) async => await productRepository.createProduct(product);
}
