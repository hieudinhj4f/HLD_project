import '../entity/product/product.dart';
import '../repository/product_repository.dart';

class GetAllProduct {
  final ProductRepository productRepository;

  GetAllProduct(this.productRepository);

  Future<List<Product>> call() async => await productRepository.getAllProducts();

}
