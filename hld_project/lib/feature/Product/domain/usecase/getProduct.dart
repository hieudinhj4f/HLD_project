import '../entity/product/product.dart';
import '../repository/product_repository.dart';

class getAllProduct {
  final ProductRepository productRepository;

  getAllProduct(this.productRepository);

  Future<List<Product>> call() async => await productRepository.getAllProducts();

}
