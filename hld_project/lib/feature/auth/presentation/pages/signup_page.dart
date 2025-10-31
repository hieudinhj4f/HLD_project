import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignupPage> {
  // Controllers cho các trường
  final emailCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final dobCtrl = TextEditingController(); // Date of Birth (DD/MM/YYYY)
  final genderCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  // KHÔNG dùng roleCtrl cho Dropdown

  String? error;
  bool _isLoading = false;

  // --- BIẾN TRẠNG THÁI CHO ROLE DROPDOWN ---
  final List<String> _roleOptions = ['user', 'admin']; // Danh sách vai trò tĩnh
  String? _selectedRole; // Vai trò đang được chọn

  // Màu sắc từ thiết kế
  static const Color primaryColor = Color(0xFF2DCC70);
  static const Color scaffoldBgColor = Color(0xFFF7F7F7);
  // static const Color fieldBgColor = Color(0xFFEFEFEF); // Màu nền của textfield
  static const Color textColor = Color(0xFF424242);

  @override
  void initState() {
    super.initState();
    // Gán giá trị mặc định cho dropdown
    _selectedRole = _roleOptions[0]; // Mặc định là 'user'
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    ageCtrl.dispose();
    dobCtrl.dispose();
    genderCtrl.dispose();
    passCtrl.dispose();
    // roleCtrl.dispose(); // Đã xoá
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      error = null;
    });

    if (passCtrl.text.isEmpty) {
      setState(() {
        error = "Please enter a password.";
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Tạo người dùng trong Firebase Auth
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );
      User? user = userCredential.user;

      // 2. Thêm thông tin chi tiết vào Firestore
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'name': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'address': addressCtrl.text.trim(),
          'age': ageCtrl.text.trim(),
          'dob': dobCtrl.text.trim(),
          'gender': genderCtrl.text.trim(),

          // SỬA LOGIC: Lấy giá trị từ _selectedRole
          'role': _selectedRole,

          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Đã đăng ký xong, GoRouter sẽ tự động chuyển hướng
      // (nếu bạn đã cài đặt authStateChanges listener)
      // Nếu không, bạn có thể chủ động chuyển hướng ở đây
      // if (mounted) context.go('/home');

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => error = e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => context.pop(), // Quay lại trang trước
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFEF), // Màu xám nhạt
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Sóng lượn ở dưới
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: SignUpWaveClipper(),
              child: Container(
                height: 200,
                color: primaryColor.withOpacity(0.8), // Màu xanh
              ),
            ),
          ),

          // 2. Form đăng ký
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Create a new account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField("Enter your email", emailCtrl),
                  const SizedBox(height: 16),
                  _buildTextField("Enter your name", nameCtrl),
                  const SizedBox(height: 16),
                  _buildTextField("Enter your phone number", phoneCtrl),
                  const SizedBox(height: 16),
                  _buildTextField("Enter your address", addressCtrl),
                  const SizedBox(height: 16),

                  // --- Hàng cho Age và DOB ---
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: _buildTextField("Age", ageCtrl),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        flex: 2,
                        child: _buildTextField("DD/MM/YYYY", dobCtrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Gender", genderCtrl),
                  const SizedBox(height: 16),
                  _buildTextField("Enter your password", passCtrl,
                      isPassword: true),
                  const SizedBox(height: 16), // Thêm khoảng cách

                  // --- SỬA LỖI LAYOUT: Dropdown ở đây ---
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: _roleOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    // Dùng chung style với TextField
                    decoration: _buildInputDecoration("Vai trò"),
                  ),
                  const SizedBox(height: 24),

                  // Hiển thị lỗi
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // --- SỬA LỖI LAYOUT: Nút "Done" ở đây ---
                  _buildDoneButton(),
                  const SizedBox(height: 40), // Đệm thêm
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets cho Style của Input
  InputDecoration _buildInputDecoration(String labelText, {bool isHint = false}) {
    return InputDecoration(
      hintText: isHint ? labelText : null,
      labelText: isHint ? null : labelText,
      hintStyle: const TextStyle(color: Colors.grey),
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white, // Hoặc fieldBgColor nếu bạn muốn nền xám
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
    );
  }

  // Helper widgets cho TextField (dùng _buildInputDecoration)
  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: !_isLoading,
      decoration: _buildInputDecoration(hintText, isHint: true),
    );
  }

  // Helper widgets cho nút "Done"
  Widget _buildDoneButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        )
            : const Text(
          "Done",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// CustomClipper cho sóng lượn (Giữ nguyên)
class SignUpWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.9,
      size.width,
      size.height * 0.6,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}