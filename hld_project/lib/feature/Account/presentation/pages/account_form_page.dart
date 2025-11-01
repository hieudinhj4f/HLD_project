// file: lib/feature/Account/presentation/pages/account_form_page.dart
// BẢN "BẨN" - FORM CỦA ADMIN (ĐÃ SỬA LỖI _selectedRole)

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // <-- THÊM IMPORT NÀY (SAU KHI PUB GET)

// === IMPORT "BẨN": UI IMPORT THẲNG TẦNG DATA ===
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';
import 'package:hld_project/feature/Account/data/repositories/account_repository_impl.dart';

// === IMPORT ENTITY VÀ USECASE (VẪN CẦN) ===
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import 'package:hld_project/feature/Account/domain/usecases/create_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/update_account.dart';
// (Mày cũng phải tạo 2 file UseCase này)

class AccountFormPage extends StatefulWidget {
  // Nhận Account (nếu là Sửa) hoặc null (nếu là Tạo mới)
  final Account? account;

  const AccountFormPage({
    super.key,
    this.account,
  });

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  // 1. STATE VARIABLES
  final _formKey = GlobalKey<FormState>();

  // Controllers (Bỏ _roleController vì dùng Radio)
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;

  String? _selectedGender;
  String? _selectedRole; // <-- SỬA: THÊM DÒNG NÀY
  bool _isSaving = false;

  // === KHAI BÁO BIẾN GIỮ USECASE "BẨN" ===
  late CreateAccount _createUseCase;
  late UpdateAccount _updateUseCase;
  late Account _originalAccount; // Biến giữ Entity gốc

  // 2. INIT STATE
  @override
  void initState() {
    super.initState();

    // =================================================
    // === PHẦN CODE "BẨN" (KHỞI TẠO TẠI CHỖ) ===

    // 1. Tự tạo DataSource (DÙNG ĐÚNG TÊN 'Ipml' CỦA MÀY)
    final dataSource = AccountRemoteDatasourceIpml(); // (Sửa Impl nếu mày đổi ý)

    // 2. Tự tạo Repository
    final repository = AccountRepositoryImpl(remoteDataSource: dataSource);
    // 3. Tự tạo UseCase
    _createUseCase = CreateAccount(repository);
    _updateUseCase = UpdateAccount(repository);
    // =================================================

    // (Code khởi tạo controller)
    final isEditing = widget.account != null;
    if (isEditing) {
      _originalAccount = widget.account!;
    } else {
      // Tạo một Account rỗng cho chế độ Create
      final now = DateTime.now();
      _originalAccount = Account(
          id: '', name: '', email: '', phone: '', gender: 'Nam', dob: '',
          age: '', address: '', role: 'user', createAt: now, updateAt: now,
          avatarUrl: ''
      );
    }

    _nameController = TextEditingController(text: _originalAccount.name);
    _emailController = TextEditingController(text: _originalAccount.email);
    _phoneController = TextEditingController(text: _originalAccount.phone);
    _dobController = TextEditingController(text: _originalAccount.dob);
    _addressController = TextEditingController(text: _originalAccount.address);

    // === SỬA: KHỞI TẠO BIẾN STATE (KHÔNG DÙNG CONTROLLER) ===
    _selectedGender = _originalAccount.gender;
    _selectedRole = _originalAccount.role;
  }

  // 3. DISPOSE (Bỏ _roleController)
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // 4. HÀM LƯU (SỬA: DÙNG _selectedRole)
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; });

    try {
      final now = DateTime.now();
      final accountToSave = Account(
        id: _originalAccount.id, // Giữ ID cũ (nếu edit)
        createAt: _originalAccount.createAt, // Giữ ngày tạo (nếu edit)

        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        gender: _selectedGender!, // Lấy từ Radio
        dob: _dobController.text,
        address: _addressController.text,
        role: _selectedRole!, // <-- SỬA: LẤY TỪ RADIO
        age: '', // (Tạm thời bỏ qua)
        updateAt: now,
        avatarUrl: _originalAccount.avatarUrl,
      );

      // Gọi UseCase "bẩn"
      if (widget.account == null) {
        await _createUseCase.call(accountToSave);
      } else {
        await _updateUseCase.call(accountToSave);
      }

      if (mounted) context.pop(true); // Trả về 'true' để báo list TẢI LẠI

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) { setState(() { _isSaving = false; }); }
    }
  }

  // (Hàm _selectDate - Giữ nguyên)
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      if (_originalAccount.dob.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(_originalAccount.dob);
      }
    } catch (_) {}
    DateTime? picked = await showDatePicker(
      context: context, initialDate: initialDate,
      firstDate: DateTime(1900), lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  // 5. BUILD (SỬA: BỎ TextFormField CỦA ROLE)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
            widget.account != null ? 'Chỉnh Sửa (Admin)' : 'Tạo Mới (Admin)',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Tên
              _buildTextField(
                controller: _nameController, label: 'Name', hintText: 'Nhập họ và tên',
                validator: (value) => value!.isEmpty ? 'Tên không được để trống' : null,
              ),
              const SizedBox(height: 24),
              // Email
              _buildTextField(
                controller: _emailController, label: 'Email', hintText: 'Nhập email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Email không hợp lệ' : null,
              ),
              const SizedBox(height: 24),
              // Phone
              _buildTextField(
                controller: _phoneController, label: 'Phone', hintText: 'Nhập số điện thoại',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              // Address
              _buildTextField(
                controller: _addressController, label: 'Address', hintText: 'Nhập địa chỉ',
              ),
              const SizedBox(height: 24),
              // Giới tính
              _buildRadioButtons(context, 'Gender', ['Nam', 'Nữ']),
              const SizedBox(height: 24),

              // === SỬA: DÙNG RADIO THAY VÌ TEXTFIELD ===
              _buildRadioButtons(context, 'Role', ['Customer', 'Mangament', 'Staff', 'Admin'], isRole: true),
              // ======================================

              const SizedBox(height: 24),
              // Ngày sinh
              _buildDatePickerField(
                context: context, controller: _dobController, label: 'Birthday', hintText: 'Chọn ngày sinh',
              ),
              const SizedBox(height: 48),
              // Nút SAVE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SAVE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (Các Widget phụ trợ y hệt ProfileEditPage)
  Widget _buildTextField({
    required TextEditingController controller, required String label, required String hintText,
    TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context, required TextEditingController controller, required String label, required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: const Icon(Iconsax.calendar_1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // (Widget Radio buttons - GIỮ NGUYÊN)
  Widget _buildRadioButtons(BuildContext context, String label, List<String> options, {bool isRole = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16.0,
          children: options.map((value) {
            // === SỬA LỖI: DÙNG _selectedRole ===
            final currentValue = isRole ? _selectedRole : _selectedGender;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: value,
                  groupValue: currentValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      if (isRole) {
                        _selectedRole = newValue;
                      } else {
                        _selectedGender = newValue;
                      }
                    });
                  },
                ),
                Text(value),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}