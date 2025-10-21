import '../entity/product/product.dart';

abstract class ProductRepository{
  Future<List<Product>> getAllProducts();

  Future<void> createProduct(Product product);

  Future<void> updateProduct(Product product);

  Future<void> deleteProduct(String id);

  Future<Product?> getProductById(String id);



}