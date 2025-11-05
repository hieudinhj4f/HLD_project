import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // ADDED
import '../../../domain/entity/product/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import '../../../domain/usecase/getProduct.dart';
import '../../../domain/usecase/createProduct.dart';
import '../../../domain/usecase/updateProduct.dart';
import '../../../domain/usecase/deleteProduct.dart';
import '../../../../auth/presentation/providers/auth_provider.dart'; // ADDED

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
    debugPrint('Checking Firestore connection...'); // <-- Đã dịch
    final firestore = FirebaseFirestore.instance;
    try {
      final snapshot = await firestore
          .collection('product')
          .doc('product')
          .get();

      if (snapshot.exists) {
        debugPrint('FIRESTORE CONNECTION SUCCESSFUL'); // <-- Đã dịch
      } else {
        debugPrint(
          'FIRESTORE CONNECTION SUCCESSFUL, but "products" document does not exist.', // <-- Đã dịch
        );
      }
    } on FirebaseException catch (e) {
      debugPrint('FIRESTORE ERROR: ${e.code}'); // <-- Đã dịch
    } catch (e) {
      debugPrint('OTHER ERROR: $e'); // <-- Đã dịch
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

  // FIXED: CHECK STOCK QUANTITY BEFORE ADDING
  Future<void> _addToCart(Product product) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add to cart'), // <-- Đã dịch
        ),
      );
      return;
    }

    // FIX: collection('product') instead of products
    final productDoc = await FirebaseFirestore.instance
        .collection('product')
        .doc(product.id)
        .get();

    if (!productDoc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product does not exist!'))); // <-- Đã dịch
      return;
    }

    final stock = (productDoc.data()?['quantity'] as num?)?.toInt() ?? 0;
    if (stock <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product is out of stock!'))); // <-- Đã dịch
      return;
    }

    // FIX: collection('cart') instead of carts
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
          const SnackBar(content: Text('Stock limit reached!')), // <-- Đã dịch
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
    ).showSnackBar(const SnackBar(content: Text('Added to cart!'))); // <-- Đã dịch
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
                hintText: 'Search', // <-- Đã dịch
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
                ? const Center(child: Text('No medication found')) // <-- Đã dịch
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