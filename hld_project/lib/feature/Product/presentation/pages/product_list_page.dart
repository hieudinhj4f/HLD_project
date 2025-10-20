import 'package:flutter/material.dart';
import 'package:hld_project/feature/Product/presentation/pages/product_form_page.dart';

import '../../domain/entity/product/product.dart';
import '../widget/product_card.dart';
import '../pages/product_form_page.dart';

class ProductListPage extends StatefulWidget {
    // Không cần constructor để nhận Use Case nữa,
    // vì chúng ta sẽ tự khởi tạo chúng bên trong State.
    const ProductListPage({super.key});

    @override
    State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {

    late final _remote = ProductRemoteDataSourceImpl();
    late final _repo = ProductRepositoryImpl(_remote);

    // Khởi tạo Use Cases (Logic Nghiệp vụ)
    late final _getProducts = GetProducts(_repo);
    late final _createProduct = CreateProduct(_repo);
    late final _updateProduct = UpdateProduct(_repo);
    late final _deleteProduct = DeleteProduct(_repo);

    // Biến trạng thái
    List<Product> _products = [];
    bool _isLoading = false;
    String? _error;

    @override
    void initState() {
        super.initState();
        // Bắt đầu tải dữ liệu ngay khi State được khởi tạo
        _loadProducts();
    }

    // --- Các Hàm Quản lý Dữ liệu ---

    Future<void> _loadProducts() async {
        setState(() {
            _isLoading = true;
            _error = null;
        });

        try {
            final products = await _getProducts.execute();
            setState(() => _products = products);
        } catch (e) {
            setState(() => _error = e.toString());
        } finally {
            setState(() => _isLoading = false);
        }
    }

    Future<void> _delete(String id) async {
        // Thêm logic xác nhận trước khi xóa (tùy chọn)
        await _deleteProduct(id);
        await _loadProducts(); // Tải lại danh sách sau khi xóa
    }

    // Hàm mở Form (Add/Edit)
    Future<void> _openForm([Product? product]) async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductFormPage(
                    product: product,
                    addUseCase: _createProduct,
                    updateUseCase: _updateProduct,
                ),
            ),
        );
        // Tải lại danh sách nếu Form trả về true (thao tác thành công)
        if (result == true) _loadProducts();
    }

    // --- Widget Xây dựng UI ---

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Danh Sách Sản Phẩm'),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _isLoading ? null : _loadProducts, // Vô hiệu hóa khi đang tải
                    ),
                ],
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () => _openForm(), // Mở form thêm mới
                child: const Icon(Icons.add),
            ),
            body: _buildBody(),
        );
    }

    Widget _buildBody() {
        // 1. Loading
        if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
        }

        // 2. Error
        if (_error != null) {
            return Center(child: Text('Lỗi: $_error. Vui lòng thử lại.'));
        }

        // 3. Empty State
        if (_products.isEmpty) {
            return const Center(child: Text('Không tìm thấy sản phẩm nào.'));
        }

        // 4. Success State
        return ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, index) {
                final p = _products[index];
                return ProductCard(
                    product: p,
                    onDetailsPressed: () => _openForm(p), // Mở form chỉnh sửa khi nhấn Open
                );
            },
        );
    }
}