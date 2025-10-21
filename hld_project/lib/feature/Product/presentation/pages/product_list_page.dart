import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

import '../../data/datasource/product_repository_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entity/product/product.dart';
import '../widget/product_card.dart';
import 'product_form_page.dart'; // ProductFormPage

import '../../domain/usecase/getProduct.dart';
import '../../domain/usecase/createProduct.dart';
import '../../domain/usecase/updateProduct.dart';
import '../../domain/usecase/deleteProduct.dart';

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
    List<Product> _filteredProducts = [];

    bool _isLoading = false;
    String? _error;
    Timer? _deboucer;

    final TextEditingController _searchController = TextEditingController();

    @override
    void initState() {
        super.initState();
        _checkFirestoreConnection();
        _loadProducts();
    }

    @override
    void dispose() {
        _deboucer?.cancel();
        _searchController.dispose();
        super.dispose();
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
            setState(() {
                _products = products;
                _performSearch(_searchController.text, runSetState: false);
                _error = null;
            });
        } catch (e) {
        setState(() => _error = e.toString());
        } finally {
        setState(() => _isLoading = false);
        }
    }

    void _performSearch(String query, {bool runSetState = true}) {
        final lowerQuery = query.toLowerCase();
        List<Product> results;

        if( lowerQuery.isEmpty) {
            results = _products;
        } else {
            results =  _products.where((Product){
                return Product.name.toLowerCase().contains(lowerQuery);
            }).toList();
        }

        if (runSetState) {
            setState(() {
                _filteredProducts = results;
            });
        }
        else {
            // Chỉ cập nhật biến, không gọi setState
            _filteredProducts = results;
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
        if (result == true) _loadProducts();
    }

    // === THAY ĐỔI ===: Hàm Debouncer khi gõ
    void _onSearchChanged(String query) {
        if (_deboucer?.isActive ?? false) _deboucer!.cancel();
        _deboucer = Timer(const Duration(milliseconds: 300), () {
            // Gọi hàm lọc sau khi người dùng ngừng gõ 300ms
            _performSearch(query);
        });
    }
    // === UI XÂY DỰNG DANH SÁCH SẢN PHẨM ===

    Widget _buildProductList() {
        if (_isLoading && _products.isEmpty) { // Check danh sách master
            return const Center(child: CircularProgressIndicator());
        }
        if (_error != null) {
            return Center(child: Text('Lỗi: $_error. Vui lòng thử lại.'));
        }

        // Check danh sách đã lọc
        if (_filteredProducts.isEmpty) {
            if (_searchController.text.isNotEmpty) {
                return const Center(child: Text('Không tìm thấy kết quả phù hợp.'));
            }
            return const Center(child: Text('Không có sản phẩm nào.'));
        }

        return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredProducts.length, // Dùng danh sách đã lọc
            itemBuilder: (context, index) {
                final p = _filteredProducts[index]; // Dùng danh sách đã lọc
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

                        // === THAY ĐỔI ===: Thanh tìm kiếm (dùng TextField)
                        TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged, // Gắn hàm debouncer
                            decoration: InputDecoration(
                                hintText: 'Tìm kiếm thuốc, bệnh lý...',
                                prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                    icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                                    onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged(''); // Xóa và lọc lại
                                    },
                                )
                                    : null,
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                ),
                            ),
                        ),
                        const SizedBox(height: 24),

                        // Ưu đãi & Khuyến mãi (Giữ nguyên)
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

                        // Tiêu đề Sản phẩm nổi bật (Giữ nguyên)
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
            // Nút Thêm mới sản phẩm (Giữ nguyên)
            floatingActionButton: FloatingActionButton(
                onPressed: () => _openForm(),
                backgroundColor: Colors.blue,
                child: const Icon(Iconsax.add, color: Colors.white),
            ),
        );
    }
}