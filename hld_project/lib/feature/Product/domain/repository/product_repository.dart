import '../entity/product/product.dart';

abstract class ProductRepository{
  Future<List<Product>> getAllProducts();

  Future<Product> createProduct(Product product);

  Future<Product> updateProduct(Product product);

  Future<void> deleteProduct(String id);

  Future<Product> getProductById(String id);

}