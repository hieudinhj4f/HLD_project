// presentation/pages/pharmacy_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../domain/entity/pharmacy.dart';
import '../../domain/usecase/createPharmacy.dart';
import '../../domain/usecase/updatePharmacy.dart';

class PharmacyFormPage extends StatefulWidget {
  final Pharmacy? pharmacy;
  final CreatePharmacy createPharmacy;
  final UpdatePharmacy updatePharmacy;

  const PharmacyFormPage({
    super.key,
    this.pharmacy,
    required this.createPharmacy,
    required this.updatePharmacy,
  });

  @override
  State<PharmacyFormPage> createState() => _PharmacyFormPageState();
}

class _PharmacyFormPageState extends State<PharmacyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final bool _isEditMode;
  bool _isLoading = false;

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _staffCountController;

  // Toggle
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.pharmacy != null;

    _nameController = TextEditingController(text: widget.pharmacy?.name ?? '');
    _imageUrlController = TextEditingController(text: widget.pharmacy?.imageUrl ?? '');
    _addressController = TextEditingController(text: widget.pharmacy?.address ?? '');
    _phoneController = TextEditingController(text: widget.pharmacy?.phone ?? '');
    _staffCountController = TextEditingController(
      text: widget.pharmacy?.staffCount.toString() ?? '0',
    );
    _isActive = widget.pharmacy?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _staffCountController.dispose();
    super.dispose();
  }

  // === SAVE ===
  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final pharmacy = Pharmacy(
        id: widget.pharmacy?.id ?? '',
        name: _nameController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        state: _isEditMode ? (widget.pharmacy?.state ?? 'Pending') : 'Pending',
        staffCount: int.tryParse(_staffCountController.text) ?? 0,
        ownerId: widget.pharmacy?.ownerId ?? 'current_user_id', // Lấy từ AuthProvider sau
        createdAt: _isEditMode ? (widget.pharmacy?.createdAt ?? now) : now,
        isActive: _isActive,
      );

      if (_isEditMode) {
        await widget.updatePharmacy(pharmacy);
      } else {
        await widget.createPharmacy(pharmacy);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Sửa Nhà Thuốc' : 'Thêm Nhà Thuốc'),
        actions: [
          _isLoading
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)),
          )
              : IconButton(icon: const Icon(Iconsax.save_2), onPressed: _onSave),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_nameController, 'Tên Nhà Thuốc', Iconsax.shop, required: true),
              _buildField(_imageUrlController, 'URL Hình Ảnh', Iconsax.gallery),
              _buildField(_addressController, 'Địa Chỉ', Iconsax.location),
              _buildField(_phoneController, 'Số Điện Thoại', Iconsax.call, keyboardType: TextInputType.phone),
              _buildField(
                _staffCountController,
                'Số Nhân Viên',
                Iconsax.people,
                keyboardType: TextInputType.number,
                required: true,
              ),

              // Toggle Active
              SwitchListTile(
                title: const Text('Hoạt động'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
                secondary: Icon(_isActive ? Iconsax.tick_circle : Iconsax.close_circle, color: _isActive ? Colors.green : Colors.red),
              ),

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _onSave,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Iconsax.save_2),
                label: Text(_isLoading
                    ? 'Đang lưu...'
                    : (_isEditMode ? 'Lưu Thay Đổi' : 'Thêm Nhà Thuốc')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        bool required = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: required
            ? (value) => (value == null || value.trim().isEmpty) ? '$label không được để trống' : null
            : null,
      ),
    );
  }
}