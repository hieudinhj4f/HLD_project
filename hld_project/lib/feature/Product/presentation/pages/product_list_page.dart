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

    // === SỬA LẠI BIẾN STATE ===
    List<Product> _allProducts = []; // 1. Danh sách "master" chứa TẤT CẢ sản phẩm
    List<Product> _filteredProducts = []; // 2. Danh sách đã lọc để hiển thị UI
    List<String> _categories = ['All']; // Danh sách các category (đã sửa tên 'Tất cả' -> 'All')
    String _selectedCategory = 'All'; // Category đang chọn

    bool _isLoading = false;
    String? _error;
    Timer? _debouncer; // Sửa lỗi chính tả

    final TextEditingController _searchController = TextEditingController();

    @override
    void initState() {
        super.initState();
        _checkFirestoreConnection();
        _loadProducts();
    }

    @override
    void dispose() {
        _debouncer?.cancel(); // Sửa lỗi chính tả
        _searchController.dispose();
        super.dispose();
    }

    Future<void> _checkFirestoreConnection() async {
        // ... (Giữ nguyên) ...
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

    // === SỬA LẠI HÀM _loadProducts ===
    Future<void> _loadProducts() async {
        setState(() {
            _isLoading = true;
            _error = null;
        });
        try {
            final products = await _getProducts.call();
            // Lấy category duy nhất (unique)
            final uniqueCategoriesName = products.map((p) => p.categories).toSet().toList();

            setState(() {
                _allProducts = products; // Gán vào danh sách "master"
                _categories = ['All', ...uniqueCategoriesName]; // Cập nhật danh sách category
                _error = null;

                // Sửa logic kiểm tra: Nếu category đã chọn không còn tồn tại, reset về 'All'
                if (!_categories.contains(_selectedCategory)) {
                    _selectedCategory = 'All';
                }
            });
        } catch (e) {
            setState(() => _error = e.toString());
        } finally {
            setState(() => _isLoading = false);
            // Luôn chạy bộ lọc sau khi tải xong
            _applyFilters();
        }
    }

    // === THAY THẾ _performSearch BẰNG HÀM NÀY ===
    void _applyFilters() {
        List<Product> tempResults = _allProducts; // Bắt đầu từ danh sách "master"
        final String query = _searchController.text.toLowerCase();

        // 1. LỌC THEO CATEGORY
        if (_selectedCategory != 'All') {
            tempResults = tempResults.where((product) {
                return product.categories == _selectedCategory;
            }).toList();
        }

        // 2. LỌC THEO TÌM KIẾM (trên kết quả đã lọc ở bước 1)
        if (query.isNotEmpty) {
            tempResults = tempResults.where((product) {
                return product.name.toLowerCase().contains(query);
            }).toList();
        }

        // 3. Cập nhật UI
        setState(() {
            _filteredProducts = tempResults;
        });
    }

    Future<void> _delete(String id) async {
        await _deleteProduct(id);
        await _loadProducts(); // Tải lại sẽ tự động lọc lại
    }

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
        if (result == true) _loadProducts(); // Tải lại sẽ tự động lọc lại
    }

    // === SỬA LẠI HÀM Debouncer ===
    void _onSearchChanged(String query) {
        if (_debouncer?.isActive ?? false) _debouncer!.cancel();
        _debouncer = Timer(const Duration(milliseconds: 300), () {
            // Gọi hàm lọc TỔNG HỢP
            _applyFilters();
        });
    }

    // === SỬA LẠI _buildProductList ĐỂ DÙNG _allProducts KHI KIỂM TRA ===
    Widget _buildProductList() {
        if (_isLoading && _allProducts.isEmpty) { // Check danh sách "master"
            return const Center(child: CircularProgressIndicator());
        }
        if (_error != null) {
            return Center(child: Text('Lỗi: $_error. Vui lòng thử lại.'));
        }

        if (_filteredProducts.isEmpty) {
            if (_searchController.text.isNotEmpty || _selectedCategory != 'All') { // Kiểm tra nếu đang lọc
                return const Center(child: Text('Không tìm thấy kết quả phù hợp.'));
            }
            return const Center(child: Text('Không có sản phẩm nào.'));
        }

        // Vẫn dùng _filteredProducts để hiển thị
        return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
                final p = _filteredProducts[index];
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
                title: const Text(  // <--- NÓ NẰM Ở ĐÂY
                    'Healthy Life Diagnosis',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                    ),
                ),
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
                        // Thanh tìm kiếm
                        TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                                // ... (Giữ nguyên) ...
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                    icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                                    onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged(''); // Xóa và gọi lại bộ lọc
                                    },
                                )
                                    : null,
                                // ... (Giữ nguyên) ...
                            ),
                        ),
                        const SizedBox(height: 24),

                        // Dropdown
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _selectedCategory,
                                    icon: const Icon(Iconsax.arrow_down_1),
                                    items: _categories.map((String categoryName) {
                                        return DropdownMenuItem<String>(
                                            value: categoryName,
                                            child: Text(categoryName),
                                        );
                                    }).toList(),
                                    // === SỬA LẠI LỖI CÚ PHÁP ===
                                    onChanged: (String? newValue) {
                                        if (newValue != null) {
                                            setState(() {
                                                _selectedCategory = newValue;
                                            });
                                            _applyFilters(); // Gọi lại bộ lọc TỔNG HỢP
                                        }
                                    },
                                ),
                            ),
                        ),
                        const SizedBox(height: 24), // Thêm khoảng cách

                        // Ưu đãi & Khuyến mãi (Giữ nguyên)
                        Container(
                            // ... (Giữ nguyên) ...
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