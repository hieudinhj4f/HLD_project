// [NEEDS THIS IMPORT IF NOT ALREADY PRESENT]
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // You already have this

// === FUNCTION TO SHOW CHANGE PASSWORD DIALOG (REFINED UI VERSION) ===
void showChangePasswordDialog(BuildContext context) {
  // These must be outside to maintain state
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _dialogError;
  bool _isLoading = false;

  showDialog(
    context: context,
    barrierDismissible: !_isLoading, // Don't allow dismissal while loading
    builder: (ctx) {
      // Use StatefulBuilder so the dialog can update its own state
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {

          // [CLEANER] Separate 'onPressed' logic into its own function
          // It's still within the 'builder' scope so it can access setDialogState
          Future<void> _submitChangePassword() async {
            setDialogState(() { _dialogError = null; });
            if (!_formKey.currentState!.validate()) {
              return;
            }

            setDialogState(() { _isLoading = true; });

            final user = fb_auth.FirebaseAuth.instance.currentUser;
            final oldPassword = _oldPasswordController.text;
            final newPassword = _newPasswordController.text;

            if (user == null || user.email == null) {
              setDialogState(() {
                _dialogError = "Error: User not found.";
                _isLoading = false;
              });
              return;
            }

            try {
              final credential = fb_auth.EmailAuthProvider.credential(
                email: user.email!,
                password: oldPassword,
              );

              await user.reauthenticateWithCredential(credential);
              await user.updatePassword(newPassword);

              // Done, so turn off loading AND close the dialog
              setDialogState(() { _isLoading = false; });
              Navigator.of(ctx).pop();

              // Show success on the main screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password changed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );

            } on fb_auth.FirebaseAuthException catch (e) {
              String errorMessage = 'An error has occurred. Please try again.';
              if (e.code == 'wrong-password' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
                errorMessage = 'The old password is incorrect.';
              } else if (e.code == 'weak-password') {
                errorMessage = 'The new password is too weak.';
              }
              setDialogState(() {
                _dialogError = errorMessage;
                _isLoading = false;
              });
            } catch (e) {
              setDialogState(() {
                _dialogError = 'Unknown error: $e';
                _isLoading = false;
              });
            }
          }

          // === REFINED UI PART ===
          return AlertDialog(
            // [NICER UI]
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: Icon(Iconsax.lock_1, color: Colors.blue.shade700, size: 44),
            title: const Text('Change password',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // [NICER UI] - Show centralized error above
                    if (_dialogError != null) ...[
                      Text(
                        _dialogError!,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
                    // [NICER UI] - Use TextFormField with OutlineBorder
                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: _buildInputDecoration('Old password'), // Dùng hàm helper
                      validator: (val) =>
                      val!.isEmpty ? 'Cannot be left blank' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: _buildInputDecoration('New password (at least 6 characters)'),
                      validator: (val) {
                        if (val!.isEmpty) return 'Cannot be left blank!';
                        if (val.length < 6)
                          return 'The password must be at least 6 characters long';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: _buildInputDecoration('Confirm new password'),
                      validator: (val) {
                        if (val!.isEmpty) return 'Cannot be left blank';
                        if (val != _newPasswordController.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Use Row to wrap 2 buttons and MainAxisAlignment.spaceBetween to push them apart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // CANCEL BUTTON (Use Expanded so it takes up 50% of space)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel'),
                           ),
                          ),
                          const SizedBox(width: 16),
                          // NÚT XÁC NHẬN (Dùng Expanded để nó chiếm 50% không gian)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isLoading ? null : _submitChangePassword,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Confirm'),
                            ),
                            onPressed: _isLoading ? null : _submitChangePassword,
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text('Confirm'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // REMOVE ALL OF THESE ACTIONS
            // actionsAlignment: MainAxisAlignment.center,
            // actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            // actions: [],
          );
        },
      );
    },
  );
}

// [NICER UI] - Extract the build InputDecoration function to keep it clean
// You must place this function OUTSIDE the showChangePasswordDialog function
InputDecoration _buildInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
    ),
  );
}