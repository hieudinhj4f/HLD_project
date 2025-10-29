import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetAllProduct {
  final ProductRepository repository;
  GetAllProduct(this.repository);

  Future<List<Product>> call() => repository.getProducts();
}
