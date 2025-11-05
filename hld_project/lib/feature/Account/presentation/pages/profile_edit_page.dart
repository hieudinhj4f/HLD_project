// file: lib/feature/Account/presentation/pages/profile_edit_page.dart
// "MAX DIRTY" VERSION - SAVE BASE64 IMAGE TO FIRESTORE

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:convert'; // <-- REQUIRED FOR ENCODE/DECODE
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// (All Storage imports removed)

// === "DIRTY" DATA LAYER IMPORTS ===
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
  Uint8List? _newAvatarBytes; // Use Bytes
  bool _isSaving = false;
  late UpdateAccount _updateUseCase;
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

    // 2. CREATE "DIRTY" USECASE
    final dataSource = AccountRemoteDatasourceIpml(); // (Fix the 'Ipml' typo if needed)
    final repository = AccountRepositoryImpl(remoteDataSource: dataSource);
    _updateUseCase = UpdateAccount(repository);

    // 3. INITIALIZE CONTROLLERS
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

  // === SAVE PROFILE FUNCTION (FIXED: SAVE BASE64 TO FIRESTORE) ===
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
        print("Encoding image to Base64...");
        // 1. Convert the bytes into a Base64 String
        String base64Image = base64Encode(_newAvatarBytes!);
        // 2. Add prefix (so the app knows this is Base64 data)
        newAvatarData = 'data:image/jpeg;base64,$base64Image';

        // (Check size - WILL CRASH IF OVER 1MB)
        if (newAvatarData.length > 1000000) {
          // Firestore has a 1MB limit per document
          throw Exception('Image too large (over 1MB), Firestore cannot save.');
        }
        print("Image encoding successful.");
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

      // === STEP 3: SAVE TO FIRESTORE ===
      await _updateUseCase.call(updatedAccount);

      // ... (Skipping AuthProvider logic) ...

      // === STEP 4: REPORT SUCCESS AND POP(TRUE) ===
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop(true); // <-- RETURN TRUE TO SIGNAL REFRESH
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating: $e')),
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
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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
                  'Select Image',
                  style: TextStyle(
                    color: Color(0xFF388E3C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // (TextFormFields unchanged)
              _buildTextField(
                controller: _nameController, label: 'Name', hintText: 'Enter full name',
                validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _phoneController, label: 'Phone Number', hintText: 'Enter phone number',
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Phone number cannot be empty' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _addressController, label: 'Address', hintText: 'Enter address',
                validator: (value) => value!.isEmpty ? 'Address cannot be empty' : null,
              ),
              const SizedBox(height: 24),
              _buildRadioButtons(context, 'Gender', ['Male', 'Female']),
              const SizedBox(height: 24),
              _buildRadioButtons(context, 'Role', ['Customer', 'Manager', 'Staff', 'Admin'], isRole: true),
              const SizedBox(height: 24),
              _buildDatePickerField(
                context: context, controller: _dobController, label: 'Date of Birth', hintText: 'Select date of birth',
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
                      : const Text('Update', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          validator: (value) => value!.isEmpty ? 'Date of birth cannot be empty' : null,
        ),
      ],
    );
  }

  // === FIX: RADIO BUTTONS (USING ROW FOR ALIGNMENT) ===
  Widget _buildRadioButtons(BuildContext context, String label, List<String> options, {bool isRole = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12), // Increase spacing a bit

        // Group of Radio buttons
        Row(
          // Use MainAxisAlignment.start to align buttons to the left
          mainAxisAlignment: MainAxisAlignment.start,
          children: options.map((value) {
            final currentValue = isRole ? _selectedRole : _selectedGender;

            // Use Flexible/SizedBox to control size if needed, but
            // here we just need a Row for alignment
            return Padding(
              padding: const EdgeInsets.only(right: 16.0), // Space between options
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Radio button (its default padding is a bit large)
                  Radio<String>(
                    value: value,
                    groupValue: currentValue,
                    activeColor: const Color(0xFF388E3C), // Main green color
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
                  // Text (placed right next to the Radio)
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