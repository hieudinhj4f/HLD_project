import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

// Import các dependencies cần thiết từ module Product (Giả định)
import '../../data/datasource/product_repository_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entity/product/product.dart';
import '../widget/product_card.dart';
import 'product_form_page.dart'; // ProductFormPage

import '../../domain/usecase/getProduct.dart';
import '../../domain/usecase/createProduct.dart';
import '../../domain/usecase/updateProduct.dart';
import '../../domain/usecase/deleteProduct.dart';

// Đây là widget Home chính, chứa cả UI và Logic Danh sách Sản phẩm
class ProductListPage extends StatefulWidget {
    const ProductListPage({Key? key}) : super(key: key);

    @override
    State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
    // === LOGIC TẢI VÀ QUẢN LÝ SẢN PHẨM (Tầng Data/Domain/Presentation) ===
    late final _remote = ProductRemoteDataSourceImpl();
    late final _repo = ProductRepositoryImpl(_remote);

    late final _getProducts = GetAllProduct(_repo);
    late final _createProduct = CreateProduct(_repo);
    late final _updateProduct = UpdateProduct(_repo);
    late final _deleteProduct = DeleteProduct(_repo);

    List<Product> _products = [];
    bool _isLoading = false;
    String? _error;
    String? SearchQuery;
    final TextEditingController _searchController = TextEditingController();


    @override
    void initState() {
        super.initState();
        _checkFirestoreConnection();
        _loadProducts(); // Bắt đầu tải danh sách sản phẩm
    }

    Future<void> _checkFirestoreConnection() async {
        // Logic kiểm tra kết nối Firestore (như cũ)
        debugPrint('Đang kiểm tra kết nối Firestore...');
        final firestore = FirebaseFirestore.instance;
        try {
            final snapshot = await firestore.collection('product').doc('products').get();

            if (snapshot.exists) {
                debugPrint('✅ KẾT NỐI FIRESTORE THÀNH CÔNG');
            } else {
                debugPrint('⚠️ KẾT NỐI FIRESTORE THÀNH CÔNG, nhưng document "products" không tồn tại.');
            }
        } on FirebaseException catch (e) {
            debugPrint('❌ LỖI FIRESTORE: ${e.code}');
        } catch (e) {
            debugPrint('❌ LỖI KHÁC: $e');
        }
    }

    Future<void> _loadProducts() async {
        setState(() {
            _isLoading = true;
            _error = null;
        });
        try {
            final products = await _getProducts.call();
            setState(() => _products = products);
        } catch (e) {
            setState(() => _error = e.toString());
        } finally {
            setState(() => _isLoading = false);
        }
    }

    Future<void> _delete(String id) async {
        await _deleteProduct(id);
        await _loadProducts();
    }

    // Hàm mở Form (Add/Edit)
    Future<void> _openForm([Product? product]) async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductFormPage(
                    product: product,
                    createUseCase: _createProduct,
                    updateUseCase: _updateProduct,
                ),
            ),
        );
        if (result == true) _loadProducts(); // Tải lại danh sách nếu thành công
    }

    // === UI XÂY DỰNG DANH SÁCH SẢN PHẨM ===

    Widget _buildProductList() {
        if (_isLoading && _products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
        }
        if (_error != null) {
            return Center(child: Text('Lỗi: $_error. Vui lòng thử lại.'));
        }
        if (_products.isEmpty) {
            return const Center(child: Text('Không tìm thấy sản phẩm nào.'));
        }

        return ListView.builder(
            // Dùng shrinkWrap và physics để nhúng vào SingleChildScrollView của trang Home
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            itemBuilder: (context, index) {
                final p = _products[index];
                return ProductCard(
                    product: p,
                    onDetailsPressed: () => _openForm(p),
                    onDeletePressed:  () => _delete(p.id),
                );
            },
        );
    }

    // === UI XÂY DỰNG TRANG HOME TỔNG THỂ ===
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text(
                    'Healthy Life Diagnosis',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
                actions: [
                    IconButton(
                        icon: const Icon(Iconsax.notification, color: Colors.black),
                        onPressed: () {},
                    ),
                    // Nút Refresh để tải lại
                    IconButton(
                        icon: const Icon(Iconsax.refresh, color: Colors.black),
                        onPressed: _isLoading ? null : _loadProducts,
                    ),
                ],
            ),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        // Thanh tìm kiếm
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                                children: [
                                    Icon(Iconsax.search_normal, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text('Tìm kiếm thuốc, bệnh lý...',
                                        style: TextStyle(color: Colors.grey)),
                                ],
                            ),
                        ),
                        const SizedBox(height: 24),

                        // Ưu đãi & Khuyến mãi
                        Container(
                            height: 150,
                            decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                                child: Text(
                                    'Ưu đãi & Khuyến mãi',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E88E5),
                                    ),
                                ),
                            ),
                        ),
                        const SizedBox(height: 24),

                        // Tiêu đề Sản phẩm nổi bật
                        const Text(
                            'Sản phẩm nổi bật',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // NHÚNG DANH SÁCH SẢN PHẨM VÀO ĐÂY
                        _buildProductList(),

                        const SizedBox(height: 40),
                    ],
                ),
            ),
            // Nút Thêm mới sản phẩm
            floatingActionButton: FloatingActionButton(
                onPressed: () => _openForm(),
                backgroundColor: Colors.blue,
                child: const Icon(Iconsax.add, color: Colors.white),
            ),
        );
    }
}