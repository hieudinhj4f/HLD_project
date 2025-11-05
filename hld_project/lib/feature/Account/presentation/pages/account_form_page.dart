// file: lib/feature/Account/presentation/pages/account_form_page.dart
// BẢN "SẠCH" 100% - DÙNG USECASE TỪ WIDGET
// "DIRTY" VERSION - FIXED REDIRECT ERROR ON CREATE

import 'package:firebase_core/firebase_core.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // <-- REQUIRED
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- REQUIRED

// === "DIRTY" IMPORT: UI IMPORTS DATA LAYER DIRECTLY ===
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';
import 'package:hld_project/feature/Account/data/repositories/account_repository_impl.dart';

// === IMPORT ENTITY, USECASE, AND RELATED PAGES ===
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import 'package:hld_project/feature/Account/domain/usecases/create_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/update_account.dart';
import 'package:hld_project/feature/Account/data/model/account_model.dart'; // <-- REQUIRED

class AccountFormPage extends StatefulWidget {
  final Account? account;

  // === NHẬN USECASE "SẠCH" ===
  final CreateAccount createAccountUseCase;
  final UpdateAccount updateAccountUseCase;

  const AccountFormPage({
    super.key,
    this.account,
    required this.createAccountUseCase,
    required this.updateAccountUseCase,
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

 
  late Account _originalAccount; 


  @override
  void initState() {
    super.initState();
    
    final isEditing = widget.account != null;
    if (isEditing) {
      _originalAccount = widget.account!;
    } else {
      // Create an empty Account for Create mode
      final now = DateTime.now();
      _originalAccount = Account(
          id: '', name: '', email: '', phone: '', gender: 'Male', dob: '',
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

  // 3. DISPOSE (GIỮ NGUYÊN)
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

  // (_pickImage and _selectDate functions remain unchanged)
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


  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; });

    try {
      final now = DateTime.now();
      String newAvatarData = _originalAccount.avatarUrl;

      // === STEP 1: ENCODE IMAGE (IF ANY) ===
      if (_newAvatarBytes != null) {
        String base64Image = base64Encode(_newAvatarBytes!);
        newAvatarData = 'data:image/jpeg;base64,$base64Image';
        if (newAvatarData.length > 1000000) {
          throw Exception('Image is too large (over 1MB), Firestore cannot save.');
        }
      }

      // === STEP 2: CHOOSE LOGIC (CREATE / EDIT) ===
      if (widget.account == null) {
        // --- CREATE LOGIC (NEW) ---

        
        final currentApp = fb_auth.FirebaseAuth.instance.app;

        // 2. Create a temporary app (with a random name)
        final String tempAppName = 'tempCreateUserApp_${DateTime.now().millisecondsSinceEpoch}';
        final fb_auth.FirebaseApp tempApp = await fb_auth.Firebase.initializeApp(
          name: tempAppName,
          options: currentApp.options,
        );

        // 3. Create an Auth instance from the temporary app
        final fb_auth.FirebaseAuth tempAuth = fb_auth.FirebaseAuth.instanceFor(app: tempApp);

        // 4. CREATE USER WITH TEMP AUTH (SO IT DOESN'T KICK OUT THE ADMIN)
        final userCredential = await tempAuth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        final newUid = userCredential.user!.uid;

        // 5. SIGN OUT AND DELETE THE TEMP APP
        await tempAuth.signOut();
        await tempApp.delete();
        // ========================================

        // B. Create Entity to save to Firestore
        final accountToSave = Account(
          id: newUid, // Use ID from Auth
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

        // === SỬA: GỌI USECASE "SẠCH" (TỪ WIDGET) ===
        await widget.createAccountUseCase.call(accountToSave);

      } else {
        // --- EDIT LOGIC (MODIFY) ---
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

        // === SỬA: GỌI USECASE "SẠCH" (TỪ WIDGET) ===
        await widget.updateAccountUseCase.call(updatedAccount);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Information updated successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
            // THAY MÀU NỀN SANG XANH LÁ
            backgroundColor: const Color(0xFF388E3C), // Màu xanh lá cây đậm (Giống nút SAVE/EDIT)
            duration: const Duration(seconds: 2),
          ),
        );
        context.pop(true); // Hoặc context.pop() nếu không cần refresh
      } // Trả về 'true' để báo list TẢI LẠI

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eror: $e')));
    } finally {
      if (mounted) { setState(() { _isSaving = false; }); }
    }
  }

  // 5. BUILD (UI GIỮ NGUYÊN)
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null; // Biến check mode

    // === LOGIC TO DISPLAY OLD IMAGE (BASE64 OR URL) ===
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
                  'Change avatar',
                  style: TextStyle(
                    color: Color(0xFF388E3C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // =========================

              const SizedBox(height: 32),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // <--- THÊM DÒNG NÀY
                children: [
                  // === EMAIL ===
                  _buildTextField(
                    controller: _emailController, label: 'Email', hintText: 'Enter email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty || !value.contains('@') ? 'Invalid email' : null,
                  ),
                  const SizedBox(height: 24),

                  // === PASSWORD (CHỈ HIỆN KHI TẠO MỚI) ===
                  if (!isEditing) ...[
                    _buildTextField(
                      controller: _passwordController, label: 'Password', hintText: 'Enter password',
                      obscureText: true,
                      validator: (value) => value!.length < 6 ? 'The password must be more than 6 characters long' : null,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // === CÁC TRƯỜNG CÒN LẠI ===
                  _buildTextField(
                    controller: _nameController, label: 'Name', hintText: 'Enter name',
                    validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _phoneController, label: 'Phone', hintText: 'Enter phone',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _addressController, label: 'Address', hintText: 'Enter address',
                  ),
                  const SizedBox(height: 24),
                  _buildRadioButtons(context, 'Gender', ['Male', 'Female']),
                  const SizedBox(height: 24),
                  // Nhớ sửa "Mangament" -> "Management" cho chuẩn nhé!
                  _buildRadioButtons(context, 'Role', ['Customer', 'Management', 'Staff', 'Admin'], isRole: true),
                  const SizedBox(height: 24),
                  _buildDatePickerField(
                    context: context, controller: _dobController, label: 'Birthday', hintText: 'Enter birthday',
                  ),
                ], // <--- KẾT THÚC COLUMN MỚI
              ),
              const SizedBox(height: 48),

              // SAVE Button
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
                      : const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (Helper Widgets _buildTextField, _buildDatePickerField, _buildRadioButtons remain unchanged)
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