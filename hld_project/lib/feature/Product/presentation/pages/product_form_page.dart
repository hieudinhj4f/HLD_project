import 'package:flutter/material.dart';

import '../../domain/entity/product/product.dart';
import '../../domain/usecase/createProduct.dart';
import '../../domain/usecase/updateProduct.dart';



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
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;


  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.product != null;
    final product = widget.product;

    _nameController = TextEditingController(text: isEditing ? product!.name : '');
    _priceController = TextEditingController(text: isEditing ? product!.price.toString() : '');
    _quantityController = TextEditingController(text: isEditing ? product!.quantity.toString() : '');
    _imageUrlController = TextEditingController(text: isEditing ? product!.imageUrl : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // --- Logic Lưu Form ---
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final newProductData = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        imageUrl: _imageUrlController.text, description: '', categories: '',

      );

      if (widget.product == null) {
        // Tình huống 1: THÊM MỚI
        await widget.createUseCase.call(newProductData);
      } else {
        // Tình huống 2: CHỈNH SỬA
        await widget.updateUseCase.call(newProductData);
      }

      Navigator.pop(context, true);

    } catch (e) {
      // Xử lý lỗi (ví dụ: hiển thị SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lưu dữ liệu: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh Sửa Sản Phẩm' : 'Thêm Sản Phẩm Mới'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
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
                decoration: const InputDecoration(labelText: 'Tên Sản Phẩm'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập tên sản phẩm.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá (Đơn vị)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) return 'Vui lòng nhập giá hợp lệ.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Số lượng'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) return 'Vui lòng nhập số lượng hợp lệ.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL Hình ảnh'),

              ),
            ],
          ),
        ),
      ),
    );
  }
}