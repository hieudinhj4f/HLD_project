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
  // --- FROM YOUR LOGIC FILE ---
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
      // GoRouter will automatically navigate if you set up
      // the authStateChanges() listener.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => error = _mapFirebaseError(e.code)); // Improved error message
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

  // (Optional) This function helps display friendlier errors
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

  // --- FROM MY UI FILE ---
  static const Color primaryColor = Color(0xFF2DCC70);
  static const Color lightGreenColor = Color(0xFFE0F7E9);
  static const Color scaffoldBgColor = Color(0xFFF7F7F7);
  static const Color textColor = Color(0xFF424242);
  static const Color subtleTextColor = Color(0xFF757575);

  // -----------------------------------------------------------------
  // --- NEW ADDITION: LOGIC TO SEND PASSWORD RESET EMAIL ---
  // -----------------------------------------------------------------
  Future<void> _sendResetEmail(String email) async {
    // Temporarily disable the login button to avoid user misclicks
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      // Success notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reset link sent. Please check your email!"),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Error notification
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
          content: Text("An error occurred. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Re-enable the login button
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- NEW ADDITION: SHOW DIALOG TO ENTER EMAIL ---
  void _showForgotPasswordDialog() {
    // This controller is only for the dialog
    final emailResetCtrl = TextEditingController();

    // If the user already entered an email in the login form, use it
    if (emailCtrl.text.isNotEmpty) {
      emailResetCtrl.text = emailCtrl.text.trim();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Forgot Password"),
        content: TextField(
          controller: emailResetCtrl,
          decoration: const InputDecoration(
            labelText: "Email",
            hintText: "Enter your email...",
          ),
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          // Send Button
          ElevatedButton(
            onPressed: () {
              final email = emailResetCtrl.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(ctx); // Close dialog
                _sendResetEmail(email); // Call the send link function
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Send Link", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  // -----------------------------------------------------------------
  // --- END OF NEW ADDITIONS ---
  // -----------------------------------------------------------------


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Wave
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

          // 2. Login Form
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

                    // --- LOGIC INTEGRATION ---
                    // E-mail Field
                    _buildTextField("E-mail", false, emailCtrl),
                    const SizedBox(height: 20.0),

                    // Password Field
                    _buildTextField("Password", true, passCtrl),
                    const SizedBox(height: 12.0),

                    // Forgot Password Link
                    _buildForgotPassword(), // <-- THIS WILL CALL THE NEW FUNCTION
                    const SizedBox(height: 24.0),

                    // --- LOGIC INTEGRATION: SHOW ERROR ---
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // --- LOGIC INTEGRATION: SIGN IN BUTTON & LOADING ---
                    _buildSignInButton(),

                    const SizedBox(height: 16.0),

                    // --- LOGIC INTEGRATION: SIGN UP BUTTON ---
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

  // --- UPDATED HELPER WIDGETS ---

  Widget _buildTextField(String label, bool isPassword, TextEditingController controller) {
    return TextField(
      controller: controller, // <-- ATTACH CONTROLLER
      obscureText: isPassword,
      enabled: !_isLoading, // <-- DISABLE WHEN LOADING
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
        disabledBorder: OutlineInputBorder( // <-- Add style for disabled state
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
        // <-- MODIFIED HERE: Call _showForgotPasswordDialog
        onPressed: _isLoading ? null : _showForgotPasswordDialog,
        child: const Text(
          "Forgot password?",
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
        // <-- DISABLE WHEN LOADING AND ATTACH _login FUNCTION
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4.0,
          shadowColor: primaryColor.withOpacity(0.5),
        ),
        // <-- SHOW SPINNER WHEN LOADING
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
          "Sign In",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Add this button to match your logic (context.go(AppRoutes.signup))
  Widget _buildSignUpButton(BuildContext context) {
    return TextButton(
      onPressed: _isLoading ? null : () => context.push(AppRoutes.signup),
      child: const Text.rich(
        TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(color: subtleTextColor, fontSize: 14),
          children: [
            TextSpan(
              text: "Sign Up",
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

// CustomClipper class to draw the wave (unchanged)
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