import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // ĐÃ THÊM
import '../../../domain/entity/product/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import '../../../domain/usecase/getProduct.dart';
import '../../../domain/usecase/createProduct.dart';
import '../../../domain/usecase/updateProduct.dart';
import '../../../domain/usecase/deleteProduct.dart';
import '../../../../auth/presentation/providers/auth_provider.dart'; // ĐÃ THÊM

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
        debugPrint('KẾT NỐI FIRESTORE THÀNH CÔNG');
      } else {
        debugPrint(
          'KẾT NỐI FIRESTORE THÀNH CÔNG, nhưng document "products" không tồn tại.',
        );
      }
    } on FirebaseException catch (e) {
      debugPrint('LỖI FIRESTORE: ${e.code}');
    } catch (e) {
      debugPrint('LỖI KHÁC: $e');
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

  // ĐÃ SỬA: KIỂM TRA SỐ LƯỢNG TRONG KHO TRƯỚC KHI THÊM
  Future<void> _addToCart(Product product) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thêm vào giỏ hàng'),
        ),
      );
      return;
    }

    // SỬA: collection('product') thay vì products
    final productDoc = await FirebaseFirestore.instance
        .collection('product')
        .doc(product.id)
        .get();

    if (!productDoc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sản phẩm không tồn tại!')));
      return;
    }

    final stock = (productDoc.data()?['quantity'] as num?)?.toInt() ?? 0;
    if (stock <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sản phẩm đã hết hàng!')));
      return;
    }

    // SỬA: collection('cart') thay vì carts
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(product.id);

    final doc = await cartRef.get();
    if (doc.exists) {
      final currentQty = (doc.data()?['quantity'] as num?)?.toInt() ?? 0;
      if (currentQty >= stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đạt giới hạn tồn kho!')),
        );
        return;
      }
      await cartRef.update({'quantity': FieldValue.increment(1)});
    } else {
      await cartRef.set({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'quantity': 1,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng!')));
  }

  // ... (phần dưới giữ nguyên 100%)

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
                hintText: 'Tìm kiếm',
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
