import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/usecase/createProduct.dart';
import '../../../domain/usecase/updateProduct.dart';
import '../../../domain/entity/product/product.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoriesController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _imageUrlController;
  late TextEditingController _pharmacyController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.product != null;
    final product = widget.product;

    _nameController = TextEditingController(text: isEditing ? product!.name : '');
    _descriptionController = TextEditingController(text: isEditing ? product?.description : '');
    _categoriesController = TextEditingController(text: isEditing ? product?.categories : '');
    _priceController = TextEditingController(text: isEditing ? product?.price.toString() : '');
    _quantityController = TextEditingController(text: isEditing ? product?.quantity.toString() : '');
    _imageUrlController = TextEditingController(text: isEditing ? product?.imageUrl : '');
    _pharmacyController = TextEditingController(text: isEditing ? product?.pharmacyId : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoriesController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    _pharmacyController.dispose();

    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = Timestamp.now();
      final productToSave = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        categories: _categoriesController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        createdAt: widget.product?.createdAt ?? now,
        updateAt: now,
        pharmacyId: _pharmacyController.text.trim(),
      );

      if (widget.product == null) {
        await widget.createUseCase.call(productToSave);
      } else {
        await widget.updateUseCase.call(productToSave);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully!')), // <-- Đã dịch
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')), // <-- Đã dịch
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'), // <-- Đã dịch
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'), // <-- Đã dịch
                validator: (value) => value?.isEmpty ?? true ? 'Product name is required' : null, // <-- Đã dịch
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'), // <-- Đã dịch
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriesController,
                decoration: const InputDecoration(labelText: 'Categories'), // <-- Đã dịch
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'), // <-- Đã dịch
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) return 'Invalid price'; // <-- Đã dịch
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'), // <-- Đã dịch
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) return 'Invalid quantity'; // <-- Đã dịch
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'), // <-- Đã dịch
              ),
            ],
          ),
        ),
      ),
    );
  }
}