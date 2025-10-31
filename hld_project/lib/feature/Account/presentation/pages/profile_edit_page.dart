// file: lib/feature/Account/presentation/pages/profile_edit_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// === IMPORT TẦNG DATA "BẨN" (Cần cho UseCase) ===
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import 'package:hld_project/feature/Account/domain/usecases/update_account.dart';
import 'package:hld_project/feature/Account/data/repositories/account_repository_impl.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';

import '../../data/datasource/account_remote_datasource.dart';


class ProfileEditPage extends StatefulWidget {
  // DỮ LIỆU ĐƯỢC NHẬN DƯỚI DẠNG MAP<STRING, DYNAMIC>
  final Map<String, dynamic> initialData;

  const ProfileEditPage({
    Key? key,
    required this.initialData,
  }) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;

  String? _selectedGender;
  String? _selectedRole;

  File? _newAvatarImage;
  bool _isSaving = false;
  late UpdateAccount _updateUseCase;
  late Account _originalAccount; // Biến giữ Entity gốc

  @override
  void initState() {
    super.initState();

    // === 1. LẤY MAP VÀ CHUYỂN THÀNH ACCOUNT ENTITY ===
    final Map<String, dynamic> data = widget.initialData; // Khai báo 'data' ở đây

    // Tự tạo object Account gốc từ Map (Cần parse các trường DateTime)
    _originalAccount = Account(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      gender: data['gender'] as String,
      dob: data['dob'] as String,
      age: data['age'] as String,
      address: data['address'] as String,
      role: data['role'] as String,
      // === FIX LỖI TYPE: PHẢI PARSE STRING THÀNH DATETIME ===
      createAt: DateTime.parse(data['createAt'] as String),
      updateAt: DateTime.parse(data['updateAt'] as String),
    );

    // === 2. TẠO USECASE "BẨN" ===
    final dataSource = AccountRemoteDatasourceIpml(); // Đã sửa tên
    final repository = AccountRepositoryImpl(remoteDataSource: dataSource);
    _updateUseCase = UpdateAccount(repository);

    // === 3. KHỞI TẠO CONTROLLER ===
    _nameController = TextEditingController(text: _originalAccount.name);
    _phoneController = TextEditingController(text: _originalAccount.phone);
    _dobController = TextEditingController(text: _originalAccount.dob);
    _addressController = TextEditingController(text: _originalAccount.address);

    _selectedGender = _originalAccount.gender;
    _selectedRole = _originalAccount.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // === HÀM CHỌN ẢNH (GIỮ NGUYÊN) ===
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _newAvatarImage = File(pickedFile.path);
      });
    }
  }

  // Chọn ngày sinh (sử dụng _originalAccount)
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      // Dùng _originalAccount
      if (_originalAccount.dob.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(_originalAccount.dob);
      }
    } catch (_) {
      // Nếu parse lỗi, dùng ngày hôm nay
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  // === HÀM LƯU PROFILE (CHỨC NĂNG EDIT) ===
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn Giới tính và Vai trò.')),
      );
      return;
    }

    setState(() { _isSaving = true; });

    try {
      final now = DateTime.now();

      // Tạo object Account mới để lưu (Dùng _originalAccount để lấy các trường cố định)
      final updatedAccount = Account(
        // Lấy các trường KHÔNG THỂ SỬA từ object gốc
        id: _originalAccount.id,
        email: _originalAccount.email,
        createAt: _originalAccount.createAt,
        age: _originalAccount.age,

        // Lấy các trường đã sửa từ Controller
        name: _nameController.text,
        phone: _phoneController.text,
        gender: _selectedGender!,
        dob: _dobController.text,
        address: _addressController.text,
        role: _selectedRole!,

        updateAt: now,
      );

      // 1. Gọi UseCase "bẩn" để lưu Profile mới
      await _updateUseCase.call(updatedAccount);

      // 2. Báo cho AuthProvider tải lại data
      final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Gọi lại AuthProvider để nó fetch data profile mới (cần phải sửa AuthProvider thành public)
        // Mày sẽ cần sửa file AuthProvider (làm hàm load data thành public) cho dòng này hoạt động
        // await context.read<AuthProvider>().onAuthStateChanged(currentUser);
        print('Profile saved, please Hot Restart to see changes.');
      }


      // 3. Báo thành công và pop
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!')),
        );
        context.pop(); // Quay lại ProfilePage (View)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật: $e')),
        );
      }
    } finally {
      if (mounted) { setState(() { _isSaving = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Toàn bộ code UI giữ nguyên) ...
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text('Chỉnh Sửa Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // === AVATAR VÀ NÚT CHANGE AVATAR ===
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _newAvatarImage != null
                        ? FileImage(_newAvatarImage!) as ImageProvider
                        : null,
                    child: _newAvatarImage == null
                        ? const Icon(Iconsax.user, size: 60, color: Colors.grey)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: const Text(
                  'Change avatar',
                  style: TextStyle(
                    color: Color(0xFF388E3C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tên
              _buildTextField(
                controller: _nameController, label: 'Name', hintText: 'Nhập họ và tên',
                validator: (value) => value!.isEmpty ? 'Tên không được để trống' : null,
              ),
              const SizedBox(height: 24),

              // Phone
              _buildTextField(
                controller: _phoneController, label: 'Phone', hintText: 'Nhập số điện thoại',
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'SĐT không được để trống' : null,
              ),
              const SizedBox(height: 24),

              // Address (Địa chỉ)
              _buildTextField(
                controller: _addressController, label: 'Address', hintText: 'Nhập địa chỉ',
                validator: (value) => value!.isEmpty ? 'Địa chỉ không được để trống' : null,
              ),
              const SizedBox(height: 24),

              // Giới tính
              _buildRadioButtons(context, 'Gender', ['Nam', 'Nữ']),
              const SizedBox(height: 24),

              // Vai trò (Dùng để thay đổi 'role' trong database)
              _buildRadioButtons(context, 'Role', ['Customer', 'Mangament', 'Staff', 'Admin'], isRole: true),

              const SizedBox(height: 24),

              // Ngày sinh
              _buildDatePickerField(
                context: context, controller: _dobController, label: 'Birthday', hintText: 'Chọn ngày sinh',
              ),

              const SizedBox(height: 48),

              // Nút EDIT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
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
                      : const Text('EDIT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (Các Widget phụ trợ giữ nguyên)
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
          validator: (value) => value!.isEmpty ? 'Ngày sinh không được để trống' : null,
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