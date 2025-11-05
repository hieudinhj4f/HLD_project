import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entity/product/product.dart';
import '../widget/product_card.dart';
import 'product_form_page.dart'; // ProductFormPage

// Import the Usecases this Page needs
import '../../../domain/usecase/getProduct.dart';
import '../../../domain/usecase/createProduct.dart';
import '../../../domain/usecase/updateProduct.dart';
import '../../../domain/usecase/deleteProduct.dart';


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
    List<String> _categories = ['All'];
    String _selectedCategory = 'All';

    bool _isLoading = false;
    String? _error;
    Timer? _debouncer;

    final TextEditingController _searchController = TextEditingController();

    @override
    void initState() {
        super.initState();
        _loadProducts();
    }

    @override
    void dispose() {
        _debouncer?.cancel();
        super.dispose();
    }


    Future<void> _loadProducts() async {
        setState(() {
            _isLoading = true;
            _error = null;
        });
        try {

            final products = await widget.getProducts.call();
            final uniqueCategoriesName = products.map((p) => p.categories).toSet().toList();

            setState(() {
                _allProducts = products;
                _categories = ['All', ...uniqueCategoriesName];
                _error = null;
                if (!_categories.contains(_selectedCategory)) {
                    _selectedCategory = 'All';
                }
            });
        } catch (e) {
            setState(() => _error = e.toString());
        } finally {
            setState(() => _isLoading = false);
            _applyFilters();
        }
    }

    void _applyFilters() {
        List<Product> tempResults = _allProducts;
        final String query = _searchController.text.toLowerCase();

        if (_selectedCategory != 'All') {
            tempResults = tempResults.where((product) {
                return product.categories == _selectedCategory;
            }).toList();
        }

        if (query.isNotEmpty) {
            tempResults = tempResults.where((product) {
                return product.name.toLowerCase().contains(query);
            }).toList();
        }

        setState(() {
            _filteredProducts = tempResults;
        });
    }
    Future<void> _delete(String id) async {
        await widget.deleteProduct(id);
        await _loadProducts();
    }

    Future<void> _openForm([Product? product]) async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductFormPage(
                    product: product,
                    createUseCase: widget.createProduct,
                    updateUseCase: widget.updateProduct,
                ),
            ),
        );
        if (result == true) _loadProducts();
    }

    void _onSearchChanged(String query) {
        if (_debouncer?.isActive ?? false) _debouncer!.cancel();
        _debouncer = Timer(const Duration(milliseconds: 300), () {
            _applyFilters();
        });
    }

    Widget _buildProductList() {
        if (_isLoading && _allProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
        }
        if (_error != null) {
            return Center(child: Text('Error: $_error. Please try again.'));
        }

        if (_filteredProducts.isEmpty) {
            if (_searchController.text.isNotEmpty || _selectedCategory != 'All') {
                return const Center(child: Text('No matching results found.'));
            }
            return const Center(child: Text('There are no products.'));
        }

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
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text(
                    'HLD',
                    style: GoogleFonts.montserrat( // <-- Change to GoogleFonts.font_name
                        fontWeight: FontWeight.w800, // This is the Black weight (super bold)
                        color: Colors.green,
                        fontSize: 30,
                    ),
                ),
                centerTitle: true,
            ),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        // Search bar
                        TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                                hintText: 'Search medicine, conditions...',
                                prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                    icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                                    onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
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
                                    onChanged: (String? newValue) {
                                        if (newValue != null) {
                                            setState(() {
                                                _selectedCategory = newValue;
                                            });
                                            _applyFilters();
                                        }
                                    },
                                ),
                            ),
                        ),
                        const SizedBox(height: 24),

                        // Offers & Promotions
                        Container(
                            height: 150,
                            decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                                child: Text(
                                    'Offers & Promotions',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E88E5),
                                    ),
                                ),
                            ),
                        ),
                        const SizedBox(height: 24),

                        // Featured Products Title
                        const Text(
                            'Featured Products',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // EMBED PRODUCT LIST HERE
                        _buildProductList(),

                        const SizedBox(height: 40),
                    ],
                ),
            ),
            // Add New Product Button
            floatingActionButton: FloatingActionButton(
                onPressed: () => _openForm(),
                backgroundColor: Colors.blue,
                child: const Icon(Iconsax.add, color: Colors.white),
            ),
        );
    }
}