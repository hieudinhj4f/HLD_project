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

  /// Thêm sản phẩm mới
  @override
  Future<void> createProduct(Product product) async {
    // 1. Ánh xạ Entity (Domain) sang Model (Data)
    final model = ProductModel.fromEntity(product);

    // 2. Gọi Data Source để thực hiện I/O
    await _remoteDataSource.add(model);
  }

  /// Cập nhật thông tin sản phẩm
  @override
  Future<void> updateProduct(Product product) async {
    // 1. Ánh xạ Entity sang Model
    final model = ProductModel.fromEntity(product);

    // 2. Gọi Data Source
    await _remoteDataSource.update(model);
  }

  /// Xóa sản phẩm theo ID
  @override
  Future<void> deleteProduct(String id) async {
    // Gọi Data Source
    await _remoteDataSource.delete(id);
  }

  /// Lấy một sản phẩm theo ID
  @override
  Future<Product?> getProductById(String id) async {
    // 1. Gọi Data Source, nhận về Model
    final model = await _remoteDataSource.getProduct(id);

    // 2. Ánh xạ Model sang Entity trước khi trả về tầng Domain
    return model?.toEntity();
  }
  /// Lấy tất cả sản phẩm
  @override
  Future<List<Product>> getAllProducts() async {
    // 1. Gọi Data Source, nhận về danh sách Models
    final models = await _remoteDataSource.getAll();

    // 2. Ánh xạ danh sách Models sang danh sách Entities
    return models.map((model) => model.toEntity()).toList();
  }
}

