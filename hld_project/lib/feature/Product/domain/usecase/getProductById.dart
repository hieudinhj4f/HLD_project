import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductById {
  final ProductRepository productRepository;

  GetProductById(this.productRepository);

  Future<Product?> call(String id) async =>
      await productRepository.getProductById(id);
}
