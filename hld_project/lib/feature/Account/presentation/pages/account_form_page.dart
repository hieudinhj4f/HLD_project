// file: lib/feature/Account/presentation/pages/account_form_page.dart
// BẢN "BẨN" - ĐÃ SỬA LỖI REDIRECT KHI CREATE

import 'package:firebase_core/firebase_core.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // <-- CẦN CÓ
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- CẦN CÓ

// === IMPORT "BẨN": UI IMPORT THẲNG TẦNG DATA ===
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';
import 'package:hld_project/feature/Account/data/repositories/account_repository_impl.dart';

// === IMPORT ENTITY, USECASE, VÀ CÁC PAGE LIÊN QUAN ===
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import 'package:hld_project/feature/Account/domain/usecases/create_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/update_account.dart';
import 'package:hld_project/feature/Account/data/model/account_model.dart'; // <-- CẦN CÓ

class AccountFormPage extends StatefulWidget {
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

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  String? _selectedGender;
  String? _selectedRole;
  bool _isSaving = false;
  Uint8List? _newAvatarBytes;

  late UpdateAccount _updateUseCase;
  late Account _originalAccount; // Biến giữ Entity gốc

  // 2. INIT STATE
  @override
  void initState() {
    super.initState();

    // === PHẦN CODE "BẨN" (KHỞI TẠO TẠI CHỖ) ===
    final dataSource = AccountRemoteDatasourceIpml(); // (Mày tự sửa tên Ipml nếu cần)
    final repository = AccountRepositoryImpl(remoteDataSource: dataSource);
    // (Bỏ CreateUseCase vì logic sai, ta sẽ tự gọi Firestore)
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
    _passwordController = TextEditingController();

    _selectedGender = _originalAccount.gender;
    _selectedRole = _originalAccount.role;
  }

  // 3. DISPOSE
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // (Hàm _pickImage và _selectDate giữ nguyên)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _newAvatarBytes = bytes;
      });
    }
  }
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

  // 4. HÀM LƯU (SỬA LẠI LOGIC CREATE ĐỂ TRÁNH REDIRECT)
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; });

    try {
      final now = DateTime.now();
      String newAvatarData = _originalAccount.avatarUrl;

      // === BƯỚC 1: ENCODE ẢNH (NẾU CÓ) ===
      if (_newAvatarBytes != null) {
        String base64Image = base64Encode(_newAvatarBytes!);
        newAvatarData = 'data:image/jpeg;base64,$base64Image';
        if (newAvatarData.length > 1000000) {
          throw Exception('Ảnh quá lớn (trên 1MB), Firestore không cho lưu.');
        }
      }

      // === BƯỚC 2: CHỌN LOGIC (CREATE / EDIT) ===
      if (widget.account == null) {
        // --- LOGIC CREATE (TẠO MỚI) ---

        // === SỬA: DÙNG MỘT APP TẠM ĐỂ TẠO AUTH ===
        // 1. Lấy config của app hiện tại (app Admin đang chạy)
        final currentApp = fb_auth.FirebaseAuth.instance.app;

        // 2. Tạo một app tạm (với tên ngẫu nhiên)
        final String tempAppName = 'tempCreateUserApp_${DateTime.now().millisecondsSinceEpoch}';
        final fb_auth.FirebaseApp tempApp = await fb_auth.Firebase.initializeApp(
          name: tempAppName,
          options: currentApp.options,
        );

        // 3. Tạo Auth instance từ app tạm
        final fb_auth.FirebaseAuth tempAuth = fb_auth.FirebaseAuth.instanceFor(app: tempApp);
        // ========================================

        // 4. TẠO USER BẰNG AUTH TẠM (ĐỂ KHÔNG ĐÁ ADMIN RA)
        final userCredential = await tempAuth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        final newUid = userCredential.user!.uid;

        // 5. ĐĂNG XUẤT VÀ XÓA APP TẠM
        await tempAuth.signOut();
        await tempApp.delete();
        // ========================================

        // B. Tạo Entity để lưu vào Firestore
        final accountToSave = Account(
          id: newUid, // Dùng ID từ Auth
          createAt: now,
          name: _nameController.text,
          email: _emailController.text.trim(),
          phone: _phoneController.text,
          gender: _selectedGender!,
          dob: _dobController.text,
          address: _addressController.text,
          role: _selectedRole!,
          age: '',
          updateAt: now,
          avatarUrl: newAvatarData,
        );

        // C. Lưu vào Firestore
        final model = AccountModel.fromEntity(accountToSave);
        await FirebaseFirestore.instance.collection('users').doc(newUid).set(model.toJson());

      } else {
        // --- LOGIC EDIT (CHỈNH SỬA) ---
        final updatedAccount = Account(
          id: _originalAccount.id,
          createAt: _originalAccount.createAt,
          age: _originalAccount.age,
          email: _emailController.text,
          name: _nameController.text,
          phone: _phoneController.text,
          gender: _selectedGender!,
          dob: _dobController.text,
          address: _addressController.text,
          role: _selectedRole!,
          updateAt: now,
          avatarUrl: newAvatarData,
        );
        await _updateUseCase.call(updatedAccount);
      }

      if (mounted) context.pop(true); // Trả về 'true' để báo list TẢI LẠI

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) { setState(() { _isSaving = false; }); }
    }
  }

  // 5. BUILD (UI)
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;

    // === LOGIC HIỂN THỊ ẢNH CŨ (BASE64 HOẶC URL) ===
    ImageProvider? currentAvatarImage;
    if (_originalAccount.avatarUrl.startsWith('data:image')) {
      try {
        currentAvatarImage = MemoryImage(base64Decode(_originalAccount.avatarUrl.split(',')[1]));
      } catch (e) { currentAvatarImage = null; }
    } else if (_originalAccount.avatarUrl.startsWith('http')) {
      currentAvatarImage = NetworkImage(_originalAccount.avatarUrl);
    }
    // ============================================

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
            isEditing ? 'Chỉnh Sửa' : 'Tạo Mới',
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
              // === UI UPLOAD ẢNH ===
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _newAvatarBytes != null
                        ? MemoryImage(_newAvatarBytes!)
                        : currentAvatarImage,
                    child: (_newAvatarBytes == null && currentAvatarImage == null)
                        ? const Icon(Iconsax.user, size: 60, color: Colors.grey)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: const Text(
                  'Chọn ảnh',
                  style: TextStyle(
                    color: Color(0xFF388E3C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // =========================

              const SizedBox(height: 32),

              // === EMAIL ===
              _buildTextField(
                controller: _emailController, label: 'Email', hintText: 'Nhập email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Email không hợp lệ' : null,
              ),
              const SizedBox(height: 24),

              // === PASSWORD (CHỈ HIỆN KHI TẠO MỚI) ===
              if (!isEditing) ...[
                _buildTextField(
                  controller: _passwordController, label: 'Mật khẩu', hintText: 'Nhập mật khẩu',
                  obscureText: true,
                  validator: (value) => value!.length < 6 ? 'Mật khẩu phải lớn hơn hoặc bằng 6 ký tự' : null,
                ),
                const SizedBox(height: 24),
              ],

              // === CÁC TRƯỜNG CÒN LẠI ===
              _buildTextField(
                controller: _nameController, label: 'Tên', hintText: 'Nhập họ và tên',
                validator: (value) => value!.isEmpty ? 'Tên không được để trống' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _phoneController, label: 'Số điện thoại', hintText: 'Nhập số điện thoại',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _addressController, label: 'Địa chỉ', hintText: 'Nhập địa chỉ',
              ),
              const SizedBox(height: 24),
              _buildRadioButtons(context, 'Giới tính', ['Nam', 'Nữ']),
              const SizedBox(height: 24),
              _buildRadioButtons(context, 'Vai trò', ['Khách hàng', 'Quản lý', 'Nhân viên', 'Admin'], isRole: true),
              const SizedBox(height: 24),
              _buildDatePickerField(
                context: context, controller: _dobController, label: 'Ngày sinh', hintText: 'Chọn ngày sinh',
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
                      : const Text('Lưu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (Các Widget phụ trợ _buildTextField, _buildDatePickerField, _buildRadioButtons giữ nguyên)
  Widget _buildTextField({
    required TextEditingController controller, required String label, required String hintText,
    TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
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

  Widget _buildRadioButtons(BuildContext context, String label, List<String> options, {bool isRole = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16.0,
          children: options.map((value) {
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