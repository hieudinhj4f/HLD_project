import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ĐÃ THÊM
import '../../domain/entities/product.dart';
import '../widget/product_card.dart';
import 'product_detail_page.dart';
import '../../domain/usecase/getProduct.dart';
import '../../domain/usecase/createProduct.dart';
import '../../domain/usecase/updateProduct.dart';
import '../../domain/usecase/deleteProduct.dart';

class ProductListPage extends StatefulWidget {
  final GetAllProduct getProducts;
  final CreateProduct createProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;

  const ProductListPage({
    Key? key,
    required this.getProducts,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
  }) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debouncer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _checkFirestoreConnection();
  }

  @override
  void dispose() {
    _debouncer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await widget.getProducts.call();
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkFirestoreConnection() async {
    debugPrint('Đang kiểm tra kết nối Firestore...');
    final firestore = FirebaseFirestore.instance;
    try {
      final snapshot = await firestore
          .collection('product')
          .doc('product')
          .get();

      if (snapshot.exists) {
        debugPrint('✅ KẾT NỐI FIRESTORE THÀNH CÔNG');
      } else {
        debugPrint(
          '⚠️ KẾT NỐI FIRESTORE THÀNH CÔNG, nhưng document "products" không tồn tại.',
        );
      }
    } on FirebaseException catch (e) {
      debugPrint('❌ LỖI FIRESTORE: ${e.code}');
    } catch (e) {
      debugPrint('❌ LỖI KHÁC: $e');
    }
  }

  void _onSearchChanged(String query) {
    if (_debouncer?.isActive ?? false) _debouncer!.cancel();
    _debouncer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _filteredProducts = _allProducts
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  Future<void> _addToCart(Product product) async {
    final cartRef = FirebaseFirestore.instance.collection('cart');
    await cartRef.add({
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'quantity': 1,
      'imageUrl': product.imageUrl,
      'timestamp': FieldValue.serverTimestamp(), // ĐÃ CÓ NHỜ IMPORT
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HLD',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Iconsax.notification), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Thuốc',
                prefixIcon: const Icon(Iconsax.search_normal),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? const Center(child: Text('Không tìm thấy thuốc'))
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(product: product),
                            ),
                          );
                        },
                        onAddToCart: () => _addToCart(product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
