import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- TỪ FILE LOGIC CỦA BẠN ---
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? error;
  bool _isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );
      // GoRouter sẽ tự động điều hướng nếu bạn set up
      // authStateChanges() listener.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => error = _mapFirebaseError(e.code)); // Cải thiện thông báo lỗi
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = "An unexpected error occurred.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // (Tùy chọn) Hàm này giúp hiển thị lỗi thân thiện hơn
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  // --- TỪ FILE UI CỦA TÔI ---
  static const Color primaryColor = Color(0xFF2DCC70);
  static const Color lightGreenColor = Color(0xFFE0F7E9);
  static const Color scaffoldBgColor = Color(0xFFF7F7F7);
  static const Color textColor = Color(0xFF424242);
  static const Color subtleTextColor = Color(0xFF757575);

  // -----------------------------------------------------------------
  // --- THÊM MỚI: LOGIC GỬI EMAIL RESET MẬT KHẨU ---
  // -----------------------------------------------------------------
  Future<void> _sendResetEmail(String email) async {
    // Tạm thời vô hiệu hoá nút login để tránh user bấm lung tung
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      // Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã gửi link reset. Vui lòng kiểm tra email!"),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mapFirebaseError(e.code)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã xảy ra lỗi. Vui lòng thử lại."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Mở lại nút login
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- THÊM MỚI: HIỂN THỊ DIALOG ĐỂ NHẬP EMAIL ---
  void _showForgotPasswordDialog() {
    // Controller này chỉ dùng cho cái dialog thôi
    final emailResetCtrl = TextEditingController();

    // Nếu user đã nhập email ở form login thì mình lấy luôn cho tiện
    if (emailCtrl.text.isNotEmpty) {
      emailResetCtrl.text = emailCtrl.text.trim();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Quên Mật Khẩu"),
        content: TextField(
          controller: emailResetCtrl,
          decoration: const InputDecoration(
            labelText: "Email",
            hintText: "Nhập email của bạn...",
          ),
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
        ),
        actions: [
          // Nút Huỷ
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Huỷ"),
          ),
          // Nút Gửi
          ElevatedButton(
            onPressed: () {
              final email = emailResetCtrl.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(ctx); // Đóng dialog
                _sendResetEmail(email); // Gọi hàm gửi link
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Gửi link", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  // -----------------------------------------------------------------
  // --- KẾT THÚC PHẦN THÊM MỚI ---
  // -----------------------------------------------------------------


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Sóng lượn
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: 200,
                color: lightGreenColor,
              ),
            ),
          ),

          // 2. Form đăng nhập
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80.0),
                    const Text(
                      "HLD",
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const Text(
                      "Healthy Life Diagnosis",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      "Health care products",
                      style: TextStyle(
                        fontSize: 16,
                        color: subtleTextColor,
                      ),
                    ),
                    const SizedBox(height: 48.0),

                    // --- TÍCH HỢP LOGIC ---
                    // Trường E-mail
                    _buildTextField("E-mail", false, emailCtrl),
                    const SizedBox(height: 20.0),

                    // Trường Password
                    _buildTextField("Password", true, passCtrl),
                    const SizedBox(height: 12.0),

                    // Link Quên mật khẩu
                    _buildForgotPassword(), // <-- CHỖ NÀY SẼ GỌI HÀM MỚI
                    const SizedBox(height: 24.0),

                    // --- TÍCH HỢP LOGIC: HIỂN THỊ LỖI ---
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // --- TÍCH HỢP LOGIC: NÚT SIGN IN & LOADING ---
                    _buildSignInButton(),

                    const SizedBox(height: 16.0),

                    // --- TÍCH HỢP LOGIC: NÚT ĐĂNG KÝ ---
                    _buildSignUpButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CẬP NHẬT HELPER WIDGETS ---

  Widget _buildTextField(String label, bool isPassword, TextEditingController controller) {
    return TextField(
      controller: controller, // <-- GẮN CONTROLLER
      obscureText: isPassword,
      enabled: !_isLoading, // <-- VÔ HIỆU HOÁ KHI LOADING
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: subtleTextColor),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primaryColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        disabledBorder: OutlineInputBorder( // <-- Thêm style khi bị vô hiệu hoá
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        // <-- SỬA Ở ĐÂY: Gọi hàm _showForgotPasswordDialog
        onPressed: _isLoading ? null : _showForgotPasswordDialog,
        child: const Text(
          "Quên mật khẩu ?",
          style: TextStyle(
            color: subtleTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        // <-- VÔ HIỆU HOÁ KHI LOADING VÀ GẮN HÀM _login
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4.0,
          shadowColor: primaryColor.withOpacity(0.5),
        ),
        // <-- HIỂN THỊ VÒNG XOAY KHI LOADING
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
          "Đăng nhập",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Thêm nút này để khớp với logic của bạn (context.go(AppRoutes.signup))
  Widget _buildSignUpButton(BuildContext context) {
    return TextButton(
      onPressed: _isLoading ? null : () => context.push(AppRoutes.signup),
      child: const Text.rich(
        TextSpan(
          text: "Chưa có tài khoản? ",
          style: TextStyle(color: subtleTextColor, fontSize: 14),
          children: [
            TextSpan(
              text: "Đăng ký",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Class CustomClipper để vẽ sóng lượn (giữ nguyên)
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.95,
      size.width,
      size.height * 0.8,
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