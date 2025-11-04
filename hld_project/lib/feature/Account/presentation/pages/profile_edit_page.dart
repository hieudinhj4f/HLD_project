// file: lib/feature/Account/presentation/pages/profile_edit_page.dart
// BẢN "BẨN HẾT CỠ" - LƯU ẢNH BASE64 VÀO FIRESTORE

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:convert'; // <-- BẮT BUỘC CÓ ĐỂ ENCODE/DECODE
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// (Vứt hết import Storage đi)

// === IMPORT TẦNG DATA "BẨN" ===
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import 'package:hld_project/feature/Account/domain/usecases/update_account.dart';
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';
import 'package:hld_project/feature/Account/data/repositories/account_repository_impl.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';


class ProfileEditPage extends StatefulWidget {
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

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  String? _selectedGender;
  String? _selectedRole;
  Uint8List? _newAvatarBytes; // Dùng Bytes
  bool _isSaving = false;
  late UpdateAccount _updateUseCase;
  late Account _originalAccount;

  @override
  void initState() {
    super.initState();

    // 1. LẤY MAP VÀ CHUYỂN THÀNH ACCOUNT ENTITY (AN TOÀN)
    final Map<String, dynamic> data = widget.initialData;
    _originalAccount = Account(
      id: data['id'] as String,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? '',
      dob: data['dob'] ?? '',
      age: data['age'] ?? '',
      address: data['address'] ?? '',
      role: data['role'] ?? 'user',
      avatarUrl: data['avatarUrl'] ?? '', // Thêm avatar
      createAt: DateTime.parse(data['createAt'] as String),
      updateAt: DateTime.parse(data['updateAt'] as String),
    );

    // 2. TẠO USECASE "BẨN"
    final dataSource = AccountRemoteDatasourceIpml(); // (Mày tự sửa tên Ipml nếu cần)
    final repository = AccountRepositoryImpl(remoteDataSource: dataSource);
    _updateUseCase = UpdateAccount(repository);

    // 3. KHỞI TẠO CONTROLLER
    _nameController = TextEditingController(text: _originalAccount.name);
    _phoneController = TextEditingController(text: _originalAccount.phone);
    _dobController = TextEditingController(text: _originalAccount.dob);
    _addressController = TextEditingController(text: _originalAccount.address);
    _selectedGender = _originalAccount.gender;
    _selectedRole = _originalAccount.role;
  }

  @override
  void dispose() {
    // (Dispose controllers...)
    super.dispose();
  }

  // === HÀM CHỌN ẢNH (ĐỌC BYTES - Giữ nguyên) ===
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

  // Chọn ngày sinh (giữ nguyên)
  Future<void> _selectDate(BuildContext context) async {
    // ... (code y cũ)
  }

  // === HÀM LƯU PROFILE (ĐÃ SỬA: LƯU BASE64 VÀO FIRESTORE) ===
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
      String newAvatarData = _originalAccount.avatarUrl; // Lấy URL/Data cũ

      // === BƯỚC 1: CHUYỂN ẢNH THÀNH TEXT (BASE64) ===
      if (_newAvatarBytes != null) {
        print("Đang encode ảnh sang Base64...");
        // 1. Chuyển đống bytes thành 1 String Base64
        String base64Image = base64Encode(_newAvatarBytes!);
        // 2. Thêm tiền tố (để app biết đây là data Base64)
        newAvatarData = 'data:image/jpeg;base64,$base64Image';

        // (Kiểm tra kích thước - NẾU TO QUÁ 1MB SẼ CRASH)
        if (newAvatarData.length > 1000000) {
          // Firestore có giới hạn 1MB cho 1 document
          throw Exception('Ảnh quá lớn (trên 1MB), Firestore không cho lưu.');
        }
        print("Encode ảnh thành công.");
      }
      // ===========================================

      // === BƯỚC 2: TẠO OBJECT VỚI DATA MỚI ===
      final updatedAccount = Account(
        id: _originalAccount.id,
        email: _originalAccount.email,
        createAt: _originalAccount.createAt,
        age: _originalAccount.age,
        name: _nameController.text,
        phone: _phoneController.text,
        gender: _selectedGender!,
        dob: _dobController.text,
        address: _addressController.text,
        role: _selectedRole!,
        updateAt: now,
        avatarUrl: newAvatarData, // <-- DÙNG DATA MỚI
      );

      // === BƯỚC 3: LƯU VÀO FIRESTORE ===
      await _updateUseCase.call(updatedAccount);

      // ... (Bỏ qua logic AuthProvider) ...

      // === BƯỚC 4: BÁO THÀNH CÔNG VÀ POP(TRUE) ===
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!')),
        );
        context.pop(true); // <-- TRẢ VỀ TRUE ĐỂ BÁO HIỆU REFRESH
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text('Chỉnh Sửa thông tin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _newAvatarBytes != null
                        ? MemoryImage(_newAvatarBytes!)
                        : (_originalAccount.avatarUrl.isNotEmpty
                        ? NetworkImage(_originalAccount.avatarUrl)
                        : null) as ImageProvider?,
                    child: (_newAvatarBytes == null && _originalAccount.avatarUrl.isEmpty)
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
              const SizedBox(height: 32),

              // (Các TextFormField giữ nguyên)
              _buildTextField(
                controller: _nameController, label: 'Tên', hintText: 'Nhập họ và tên',
                validator: (value) => value!.isEmpty ? 'Tên không được để trống' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _phoneController, label: 'Số điện thoại', hintText: 'Nhập số điện thoại',
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Số điện thoại không được để trống' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _addressController, label: 'Địa chỉ', hintText: 'Nhập địa chỉ',
                validator: (value) => value!.isEmpty ? 'Địa chỉ không được để trống' : null,
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

              // Nút EDIT (Giữ nguyên)
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
                      : const Text('Cập nhật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // === HÀM SỬA: RADIO BUTTONS (DÙNG ROW CĂN CHỈNH) ===
  Widget _buildRadioButtons(BuildContext context, String label, List<String> options, {bool isRole = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12), // Tăng khoảng cách chút cho đẹp

        // Group các nút Radio
        Row(
          // Dùng MainAxisAlignment.start để các nút căn sát lề trái
          mainAxisAlignment: MainAxisAlignment.start,
          children: options.map((value) {
            final currentValue = isRole ? _selectedRole : _selectedGender;

            // Dùng Flexible/SizedBox để kiểm soát kích thước nếu cần, nhưng
            // ở đây ta chỉ cần Row để căn chỉnh
            return Padding(
              padding: const EdgeInsets.only(right: 16.0), // Khoảng cách giữa các lựa chọn
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nút Radio (Padding mặc định của nó hơi lớn)
                  Radio<String>(
                    value: value,
                    groupValue: currentValue,
                    activeColor: const Color(0xFF388E3C), // Màu xanh lá chủ đạo
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
                  // Text (đặt ngay cạnh Radio)
                  Text(value, style: const TextStyle(fontSize: 15)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}