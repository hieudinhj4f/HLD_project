// file: lib/feature/Account/presentation/pages/profile_edit_page.dart
// BẢN "SẠCH" 100% - NHẬN USECASE TỪ CONSTRUCTOR

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:convert'; // <-- BẮT BUỘC CÓ ĐỂ ENCODE/DECODE

// === XÓA IMPORT "BẨN" ===
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import 'package:hld_project/feature/Account/domain/usecases/update_account.dart';

class ProfileEditPage extends StatefulWidget {
  final Map<String, dynamic> initialData;

  // === THÊM DÒNG NÀY (ĐỂ NHẬN USECASE "SẠCH") ===
  final UpdateAccount updateAccountUseCase;

  const ProfileEditPage({
    Key? key,
    required this.initialData,
    required this.updateAccountUseCase, // <-- THÊM REQUIRED
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
  Uint8List? _newAvatarBytes; // Use Bytes
  bool _isSaving = false;
  // late UpdateAccount _updateUseCase; // <-- XÓA BIẾN "BẨN"
  late Account _originalAccount;

  @override
  void initState() {
    super.initState();

    // 1. GET MAP AND CONVERT TO ACCOUNT ENTITY (SAFELY)
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
      avatarUrl: data['avatarUrl'] ?? '', // Add avatar
      createAt: DateTime.parse(data['createAt'] as String),
      updateAt: DateTime.parse(data['updateAt'] as String),
    );

    // 2. === XÓA HẾT CODE TẠO USECASE "BẨN" ===
    // (Xóa dataSource = ..., repository = ..., _updateUseCase = ...)
    // =======================================

    // 3. KHỞI TẠO CONTROLLER (GIỮ NGUYÊN)
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

  // === PICK IMAGE FUNCTION (READ BYTES - Unchanged) ===
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

  // Select date of birth (unchanged)
  Future<void> _selectDate(BuildContext context) async {
    // ... (same old code)
  }

  // === HÀM LƯU PROFILE (SỬA: DÙNG USECASE "SẠCH") ===
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Gender and Role.')),
      );
      return;
    }

    setState(() { _isSaving = true; });

    try {
      final now = DateTime.now();
      String newAvatarData = _originalAccount.avatarUrl; // Get old URL/Data

      // === STEP 1: CONVERT IMAGE TO TEXT (BASE64) ===
      if (_newAvatarBytes != null) {
        // (Code encode Base64 y như cũ)
        String base64Image = base64Encode(_newAvatarBytes!);
        newAvatarData = 'data:image/jpeg;base64,$base64Image';
        if (newAvatarData.length > 1000000) {
          throw Exception('The image is too large (over 1MB), Firestore does not allow saving it.');
        }
      }
      // ===========================================

      // === STEP 2: CREATE OBJECT WITH NEW DATA ===
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
        avatarUrl: newAvatarData, // <-- USE NEW DATA
      );

      // === BƯỚC 3: LƯU VÀO FIRESTORE (DÙNG USECASE "SẠCH") ===
      await widget.updateAccountUseCase.call(updatedAccount);

      // (Bỏ qua logic AuthProvider)

      // === STEP 4: REPORT SUCCESS AND POP(TRUE) ===
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Information updated successfully!'),
              backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // <-- RETURN TRUE TO SIGNAL REFRESH
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error when updating: $e')),
        );
      }
    } finally {
      if (mounted) { setState(() { _isSaving = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    // === TOÀN BỘ CODE UI GIỮ NGUYÊN ===
    // (Nó dùng _newAvatarBytes để hiển thị MemoryImage,
    // nên UI không cần sửa)

    // (Logic decode ảnh cũ)
    ImageProvider? currentAvatarImage;
    if (_originalAccount.avatarUrl.startsWith('data:image')) {
      try {
        currentAvatarImage = MemoryImage(base64Decode(_originalAccount.avatarUrl.split(',')[1]));
      } catch (e) { currentAvatarImage = null; }
    } else if (_originalAccount.avatarUrl.startsWith('http')) {
      currentAvatarImage = NetworkImage(_originalAccount.avatarUrl);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => context.pop(),
        ),
          backgroundColor: Colors.white,
          title: Text(
            'HLD',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800,
              color: Colors.green,
              fontSize: 30,
            ),
          ),
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
                  'Change avatar',
                  style: TextStyle(
                    color: Color(0xFF388E3C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // <-- THÊM VÀO ĐÂY
                children: [
                  _buildTextField(
                    controller: _nameController, label: 'Name', hintText: 'Enter name',
                    validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _phoneController, label: 'Phone', hintText: 'Enter phone',
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Phone number cannot be left blank' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _addressController, label: 'Address', hintText: 'Enter address',
                    validator: (value) => value!.isEmpty ? 'Address cannot be empty' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildRadioButtons(context, 'Gender', ['Male', 'Female']),
                  const SizedBox(height: 24),
                  // Nhớ sửa lỗi chính tả "Mangament" -> "Management" nhé
                  _buildRadioButtons(context, 'Role', ['Customer', 'Management', 'Staff', 'Admin'], isRole: true),
                  const SizedBox(height: 24),
                  _buildDatePickerField(
                    context: context, controller: _dobController, label: 'Birthday', hintText: 'Select birth date',
                  ),
                ], // <-- KẾT THÚC CHILDREN CỦA COLUMN MỚI
              ),
              const SizedBox(height: 48),

              // EDIT Button (Unchanged)
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

  // (Helper Widgets _buildTextField, _buildDatePickerField, _buildRadioButtons unchanged)
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
          validator: (value) => value!.isEmpty ? 'Date of birth cannot be left blank' : null,
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