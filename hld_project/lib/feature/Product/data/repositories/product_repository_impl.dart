import 'package:hld_project/feature/Product/domain/entity/product/product.dart';
import 'package:hld_project/feature/Product/domain/repository/product_repository.dart';

// Giả định các imports sau nằm trong tầng Data
import '../datasource/product_repository_datasource.dart';
import '../model/product_model.dart';

/// Implementation of ProductRepository (Data Layer)
/// Chịu trách nhiệm chính là Ánh xạ (Mapping) và Quản lý luồng dữ liệu.
class ProductRepositoryImpl implements ProductRepository {
  // Dependency Injection của Data Source
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  // --- Triển khai các phương thức từ ProductRepository (Domain) ---

  @override
  Future<void> createProduct(Product product) async {
    // 1. Ánh xạ Entity (Domain) sang Model (Data)
    final model = ProductModel.fromEntity(product);
    // 2. Gọi Data Source để thực hiện I/O
    await _remoteDataSource.add(model);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final model = ProductModel.fromEntity(product);
    await _remoteDataSource.update(model);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _remoteDataSource.delete(id);
  }

  @override
  Future<Product?> getProductById(String id) async {
    final model = await _remoteDataSource.getProduct(id);

    return model?.toEntity();
  }
  @override
  Future<List<Product>> getAllProducts() async {
    final models = await _remoteDataSource.getAll();
    return models.map((model) => model.toEntity()).toList();
  }
}

