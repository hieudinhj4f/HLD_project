import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Product>> getProducts() async {
    final models = await _remoteDataSource.getProducts();
    return models.map((m) => Product(
          id: m.id,
          name: m.name,
          description: m.description,
          categories: m.categories,
          imageUrl: m.imageUrl,
          price: m.price,
          quantity: m.quantity,
          createdAt: m.createdAt,
          updateAt: m.updateAt,
        )).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final doc = await _remoteDataSource.getProductById(id);
    if (doc == null) return null;
    final model = ProductModel.fromFirestore(doc);
    return Product(
      id: model.id,
      name: model.name,
      description: model.description,
      categories: model.categories,
      imageUrl: model.imageUrl,
      price: model.price,
      quantity: model.quantity,
      createdAt: model.createdAt,
      updateAt: model.updateAt,
    );
  }

  @override
  Future<void> createProduct(Product product) async {
    final model = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      categories: product.categories,
      imageUrl: product.imageUrl,
      price: product.price,
      quantity: product.quantity,
      createdAt: product.createdAt,
      updateAt: product.updateAt,
    );
    await _remoteDataSource.createProduct(model);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final model = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      categories: product.categories,
      imageUrl: product.imageUrl,
      price: product.price,
      quantity: product.quantity,
      createdAt: product.createdAt,
      updateAt: product.updateAt,
    );
    await _remoteDataSource.updateProduct(model);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _remoteDataSource.deleteProduct(id);
  }
}