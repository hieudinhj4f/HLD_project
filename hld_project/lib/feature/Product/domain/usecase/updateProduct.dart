import "../entity/product/product.dart";
import '../repository/product_repository.dart';

class UpdateProduct {
  final ProductRepository productRepository;

  UpdateProduct(this.productRepository);

  Future<Product> call(Product product) async => await productRepository.updateProduct(product);
}