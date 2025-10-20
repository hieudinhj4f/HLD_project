import '../entity/product/product.dart';
import '../repository/product_repository.dart';

class DeleteProduct{
  final ProductRepository productRepository;

  DeleteProduct(this.productRepository);

  Future<void> call(String id) async => await productRepository.deleteProduct(id);
}