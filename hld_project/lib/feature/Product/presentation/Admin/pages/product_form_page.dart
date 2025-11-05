import 'package:flutter/material.dart';
// Importing 'cloud_firestore.dart' is sufficient for both mobile and web
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entity/product/product.dart';
import '../../../domain/usecase/createProduct.dart';
import '../../../domain/usecase/updateProduct.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product; // Product (nullable) passed in for editing
  final CreateProduct createUseCase;
  final UpdateProduct updateUseCase;

  const ProductFormPage({
    super.key,
    this.product,
    required this.createUseCase,
    required this.updateUseCase,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  // 1. STATE VARIABLES

  // This key is used to track and validate the Form
  final _formKey = GlobalKey<FormState>();

  // Controllers to "control" the text fields
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _imageUrlController;
  // === FIX: Add missing controllers ===
  late TextEditingController _descriptionController;
  late TextEditingController _categoriesController;
  // (categoryId would be better, but using categories (String) based on your code)

  // State variable for loading
  bool _isSaving = false;

  // 2. INIT STATE (Initialization)
  @override
  void initState() {
    super.initState();

    final isEditing = widget.product != null;
    final product = widget.product;

    _nameController = TextEditingController(text: isEditing ? product!.name : '');
    _priceController = TextEditingController(text: isEditing ? product!.price.toString() : '');
    _quantityController = TextEditingController(text: isEditing ? product!.quantity.toString() : '');
    _imageUrlController = TextEditingController(text: isEditing ? product!.imageUrl : '');
    _descriptionController = TextEditingController(text: isEditing ? product!.description : '');
    _categoriesController = TextEditingController(text: isEditing ? product!.categories : '');

    // The 2 Timestamp variables you declared don't need to be state variables,
    // because their values are set on SAVE, not entered by the user.
    // We will handle them in the _saveForm() function.
  }

  // 3. DISPOSE (Cleanup)
  @override
  void dispose() {
    // === FIX: Dispose ALL controllers to avoid memory leaks ===
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = Timestamp.now();
      final productToSave = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        imageUrl: _imageUrlController.text,
        // === FIX: Get values from controllers instead of empty strings ===
        description: _descriptionController.text,
        categories: _categoriesController.text,
        createdAt: widget.product?.createdAt ?? now,
        updateAt: now,
      );

      // 4.5. Call UseCase
      if (widget.product == null) {
        // Scenario 1: ADD NEW
        await widget.createUseCase.call(productToSave);
      } else {
        // Scenario 2: EDIT
        await widget.updateUseCase.call(productToSave);
      }

      // 4.6. Close form if successful
      // Return 'true' to let the previous page (ProductListPage) know it needs to reload the list
      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      // 4.7. Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    } finally {
      // 4.8. Turn off loading state (whether success or failure)
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // 5. BUILD (Build UI)
  @override
  Widget build(BuildContext context) {
    // Get this variable again for readability
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
        actions: [
          // Save button with loading state
          IconButton(
            icon: _isSaving
                ? const SizedBox( // Show spinner if saving
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
            )
                : const Icon(Icons.save), // Show save icon
            // Disable button when saving
            onPressed: _isSaving ? null : _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Attach key to Form
          child: ListView( // Use ListView to avoid overflow errors when keyboard appears
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) { // Validation logic
                  if (value == null || value.isEmpty) return 'Please enter a product name.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number, // Number keyboard
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) return 'Please enter a valid price.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) return 'Please enter a valid quantity.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                // Not required, so no validator needed
              ),
              const SizedBox(height: 16),

              // === FIX: Add missing UI fields ===
              TextFormField(
                controller: _categoriesController,
                decoration: const InputDecoration(labelText: 'Category (ID)'),
                // (You should change this to a DropdownButton later)
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                maxLines: 3, // Allow multiple lines
              ),
            ],
          ),
        ),
      ),
    );
  }
}