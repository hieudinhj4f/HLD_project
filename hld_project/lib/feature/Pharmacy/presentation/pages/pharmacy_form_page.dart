import 'package:flutter/material.dart';
import '../../domain/entity/pharmacy.dart';

class PharmacyFormPage extends StatefulWidget {
  // Nếu pharmacy là null, đây là form 'Tạo mới'
  // Nếu pharmacy có dữ liệu, đây là form 'Chỉnh sửa'
  final Pharmacy? pharmacy;

  const PharmacyFormPage({super.key, this.pharmacy});

  @override
  State<PharmacyFormPage> createState() => _PharmacyFormPageState();
}

class _PharmacyFormPageState extends State<PharmacyFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _destController;
  late final TextEditingController _hotlineController;
  late final TextEditingController _taxIdController;
  late final TextEditingController _presController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với dữ liệu có sẵn (nếu là 'Edit')
    _nameController = TextEditingController(text: widget.pharmacy?.name ?? '');
    _destController =
        TextEditingController(text: widget.pharmacy?.destination ?? '');
    _hotlineController =
        TextEditingController(text: widget.pharmacy?.hotline ?? '');
    _taxIdController =
        TextEditingController(text: widget.pharmacy?.taxId ?? '');
    _presController =
        TextEditingController(text: widget.pharmacy?.presentative ?? '');
  }

  @override
  void dispose() {
    // Luôn dispose controller
    _nameController.dispose();
    _destController.dispose();
    _hotlineController.dispose();
    _taxIdController.dispose();
    _presController.dispose();
    super.dispose();
  }

  void _onSave() {
    // Kiểm tra tính hợp lệ của form
    if (_formKey.currentState?.validate() ?? false) {
      // Gọi Usecase/Provider để lưu dữ liệu
      print('Saving data...');
      print('Name: ${_nameController.text}');

      // Sau khi lưu, quay lại trang trước
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.pharmacy == null ? 'Add Pharmacy' : 'Edit Pharmacy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _onSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextFormField(
                controller: _nameController,
                label: 'Pharmacy Name',
                icon: Icons.store,
              ),
              _buildTextFormField(
                controller: _destController,
                label: 'Destination (Address)',
                icon: Icons.location_on,
              ),
              _buildTextFormField(
                controller: _hotlineController,
                label: 'Hotline',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextFormField(
                controller: _taxIdController,
                label: 'Tax ID',
                icon: Icons.description,
              ),
              _buildTextFormField(
                controller: _presController,
                label: 'Presentative',
                icon: Icons.person,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                onPressed: _onSave,
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget con để tạo TextFormField cho gọn
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}