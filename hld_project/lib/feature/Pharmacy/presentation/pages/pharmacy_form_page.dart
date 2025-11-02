import 'package:flutter/material.dart';
// 1. IMPORT USECASE VÀ ENTITY
import '../../domain/entity/pharmacy.dart';
import '../../domain/usecase/createPharmacy.dart';
import '../../domain/usecase/updatePharmacy.dart';

class PharmacyFormPage extends StatefulWidget {
  final Pharmacy? pharmacy;

  // 2. NHẬN CÁC USECASE
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

  late final TextEditingController _nameController;
  late final TextEditingController _destController;
  late final TextEditingController _hotlineController;
  late final TextEditingController _taxIdController;
  late final TextEditingController _presController;
  // (Bạn cũng cần controller cho 'imageUrl' nếu có)
  late final TextEditingController _imageUrlController;

  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _isEditMode = (widget.pharmacy != null);

    _nameController = TextEditingController(text: widget.pharmacy?.name ?? '');
    _destController =
        TextEditingController(text: widget.pharmacy?.destination ?? '');
    _hotlineController =
        TextEditingController(text: widget.pharmacy?.hotline ?? '');
    _taxIdController =
        TextEditingController(text: widget.pharmacy?.taxId ?? '');
    _presController =
        TextEditingController(text: widget.pharmacy?.presentative ?? '');
    // Khởi tạo controller cho imageUrl
    _imageUrlController =
        TextEditingController(text: widget.pharmacy?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destController.dispose();
    _hotlineController.dispose();
    _taxIdController.dispose();
    _presController.dispose();
    _imageUrlController.dispose(); // <-- Nhớ dispose
    super.dispose();
  }

  // 3. VIẾT LẠI HÀM _onSave
  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      // (Bạn có thể thêm logic hiển thị loading ở đây)

      // A. Gom dữ liệu từ form
      final pharmacyData = Pharmacy(
        // Nếu là 'Edit', dùng ID cũ.
        // Nếu là 'Add', Firebase sẽ tự tạo ID,
        // nên ta truyền 1 ID tạm (ví dụ: 'new' hoặc rỗng)
        // (Kiểm tra lại Entity của bạn, nếu id không phải 'String?'
        // mà là 'String', bạn bắt buộc phải truyền 1 giá trị)
        id: widget.pharmacy?.id ?? '',
        name: _nameController.text,
        destination: _destController.text,
        hotline: _hotlineController.text,
        taxId: _taxIdController.text,
        presentative: _presController.text,
        imageUrl: _imageUrlController.text,
      );

      try {
        // B. Quyết định gọi Usecase nào
        if (_isEditMode) {
          // Chế độ Cập nhật
          print('Updating pharmacy...');
          widget.updatePharmacy(pharmacyData); // <-- GỌI UPDATE USECASE
        } else {
          // Chế độ Tạo mới
          print('Creating new pharmacy...');
          widget.createPharmacy(pharmacyData); // <-- GỌI CREATE USECASE
        }

        // C. Quay lại trang trước
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        // (Xử lý lỗi nếu có)
        print('Failed to save pharmacy: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Pharmacy' : 'Add Pharmacy'),
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
              // THÊM TRƯỜNG IMAGE URL
              _buildTextFormField(
                controller: _imageUrlController,
                label: 'Image URL',
                icon: Icons.image,
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
                // Cập nhật tiêu đề nút
                label: Text(_isEditMode ? 'Save Changes' : 'Add Pharmacy'),
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

  // (Widget _buildTextFormField giữ nguyên)
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