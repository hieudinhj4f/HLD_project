// file: lib/feature/Account/presentation/pages/profile_page.dart
// BẢN "HOÀN CHỈNH" - ĐÃ SỬA SPACING, DIALOG, VÀ CÁC NÚT

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import 'dart:convert'; // <-- BẮT BUỘC CÓ
import 'dart:typed_data'; // <-- BẮT BUỘC CÓ

// === IMPORT AUTHPROVIDER ĐỂ CHECK ROLE ===
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';
// === IMPORT "BẨN" CHO NÚT XÓA ===
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';
import 'package:hld_project/feature/Account/data/repositories/account_repository_impl.dart';
import 'package:hld_project/feature/Account/domain/usecases/delete_account.dart';

import '../../data/model/account_model.dart';
import '../../domain/entities/account.dart';
import 'changePassword.dart';
import 'profile_edit_page.dart'; // Import trang Edit
import 'package:google_fonts/google_fonts.dart';


// === 1. ĐỔI THÀNH STATEFULWIDGET ===
class ProfilePage extends StatefulWidget {
  // NHẬN ACCOUNT TÙY CHỌN (NẾU ADMIN GỌI "OPEN")
  final Account? account;

  const ProfilePage({Key? key, this.account}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Account> _profileFuture;
  Account? _userToDisplay;
  bool _isViewingOtherUser = false;

  @override
  void initState() {
    super.initState();

    if (widget.account != null) {
      _userToDisplay = widget.account;
      _isViewingOtherUser = true;
    } else {
      _profileFuture = _fetchMyProfile();
      _isViewingOtherUser = false;
    }
  }

  // === HÀM TỰ LẤY DATA (CHO TRƯỜNG HỢP 2) ===
  Future<Account> _fetchMyProfile() async {
    final String? uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('You are not logged in!');
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return AccountModel.fromFirestore(doc);
      } else {
        throw Exception('Profile information not found.');
      }
    } catch (e) {
      throw Exception('Error loading profile: ${e.toString()}');
    }
  }

  // === HÀM XÓA (BẢN "XỊN") ===
  Future<void> _deleteAccount(String accountId) async {
    // Phần logic use case giữ nguyên
    final dataSource = AccountRemoteDatasourceIpml();
    final repository = AccountRepositoryImpl(remoteDataSource: dataSource);
    final deleteUseCase = DeleteAccount(repository);

    final confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // 1. Icon cảnh báo
        icon: Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 50),

        // 2. Title
        title: const Text('Confirm deletion', style: TextStyle(fontWeight: FontWeight.bold)),

        // 3. Content (thêm câu cảnh báo)
        content: const Text(
          'Are you sure you want to delete this account? \nThis action cannot be undone.',
          textAlign: TextAlign.center, // Căn giữa text
        ),

        // 5. Căn 2 nút ra giữa
        actionsAlignment: MainAxisAlignment.center,

        actions: [
          // 4. Nút Hủy (style OutlinedButton)
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),

          const SizedBox(width: 10), // Khoảng cách giữa 2 nút

          // 4. Nút Xóa (style ElevatedButton màu đỏ)
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    // Phần logic xử lý sau khi dialog đóng
    if (confirmed == true) {
      try {
        await deleteUseCase.call(accountId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Account deleted successfully.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                // THÊM DÒNG NÀY ĐỂ ĐỔI NỀN
                backgroundColor:Colors.green, // Màu xanh lá chủ đạo
                duration: const Duration(seconds: 2),
              )
          );
          context.pop(true);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error when deleting: $e')));
      }
    }
  }


  // Hàm helper (check null/rỗng)
  String _displayValue(String? value) {
    return (value == null || value.isEmpty) ? 'Not updated' : value;
  }

  // === HÀM CHUYỂN ACCOUNT OBJECT THÀNH MAP<STRING, STRING> THỦ CÔNG ===
  Map<String, String> _createProfileMap(Account user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'gender': user.gender,
      'dob': user.dob,
      'age': user.age,
      'address': user.address,
      'role': user.role,
      'avatarUrl': user.avatarUrl, // Thêm avatar
      'createAt': user.createAt.toIso8601String(),
      'updateAt': user.updateAt.toIso8601String(),
    };
  }

  // === WIDGET DÒNG TEXT PHẲNG (ĐÃ SỬA SPACING + CĂN PHẢI) ===
  Widget _buildTextField(String label, String value) {
    return Padding(
      // Tăng padding ngang và dọc
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn 2 bên
        children: [
          // Label
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),

          // Value (dùng Expanded để nó đẩy ra hết cỡ bên phải)
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right, // <-- Căn phải
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, // Xử lý tràn text (nếu có)
              maxLines: 2, // Cho phép hiển thị tối đa 2 dòng nếu dài
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext cxt) { // Đổi tên context để tránh nhầm lẫn
    // === LOGIC BUILD CHÍNH ===
    if (!_isViewingOtherUser) {
      return Scaffold(
        appBar: _buildProfileAppBar(cxt, isAdmin: cxt.read<AuthProvider>().isAdmin),
        body: FutureBuilder<Account>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text('Eror: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: Text('No data found.'));
            final Account user = snapshot.data!;
            return _buildProfileBody(context, user, isAdmin: cxt.read<AuthProvider>().isAdmin);
          },
        ),
      );
    }

    return Scaffold(
      appBar: _buildProfileAppBar(cxt, isAdmin: true),
      body: _buildProfileBody(cxt, _userToDisplay!, isAdmin: true),
    );
  }


  // === TÁCH APPBAR RA CHO SẠCH (Đã bỏ nút logout) ===
  AppBar _buildProfileAppBar(BuildContext context, {required bool isAdmin}) {
    return AppBar(
      leading: _isViewingOtherUser
          ? IconButton(icon: const Icon(Iconsax.arrow_left, color: Colors.black), onPressed: () => context.pop())
          : null,
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
      // ĐÃ XÓA ACTIONS (NÚT LOGOUT)
    );
  }

  // === TÁCH BODY UI (ĐÃ SỬA DECODE ẢNH VÀ CÁC NÚT BẤM) ===
  Widget _buildProfileBody(BuildContext context, Account user, {required bool isAdmin}) {

    // === LOGIC GIẢI MÃ (DECODE) ẢNH ===
    ImageProvider? avatarImage;
    if (user.avatarUrl.startsWith('data:image')) {
      try {
        final String base64String = user.avatarUrl.split(',')[1];
        final Uint8List imageBytes = base64Decode(base64String);
        avatarImage = MemoryImage(imageBytes);
      } catch (e) {
        avatarImage = null; // Lỗi decode
      }
    } else if (user.avatarUrl.startsWith('http')) {
      avatarImage = NetworkImage(user.avatarUrl);
    }
    // =================================

    return SingleChildScrollView(
      child: Container(
        color: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: avatarImage,
              child: (avatarImage == null)
                  ? const Icon(Iconsax.user, size: 50, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // === KHUNG THÔNG TIN TRẮNG (FLAT TEXT) ===
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              // Bỏ padding vertical ở đây, vì _buildTextField đã có
              padding: const EdgeInsets.symmetric(vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5) ],
              ),
              child: Column(
                children: [
                  _buildTextField('Name', _displayValue(user.name)),
                  const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                  _buildTextField('Phone', _displayValue(user.phone)),
                  const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                  _buildTextField('Gender', _displayValue(user.gender)),
                  const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                  _buildTextField('Birthday', _displayValue(user.dob)),
                  const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                  _buildTextField('Address', _displayValue(user.address)),
                  if (isAdmin) ...[
                    const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                    _buildTextField('Role', _displayValue(user.role)),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 48),

            // === KHU VỰC CÁC NÚT (ĐÃ SỬA) ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: _isViewingOtherUser
                // === NÚT XÓA (ADMIN XEM) ===
                    ? ElevatedButton(
                  onPressed: () => _deleteAccount(user.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Delete This Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                )
                // === NÚT CHỈNH SỬA (TỰ XEM) ===
                    : ElevatedButton(
                  onPressed: () async {
                    final Map<String, String> profileData = _createProfileMap(user);
                    final String editPath = isAdmin ? '/admin/account/edit' : '/user/account/edit';
                    final result = await context.push(editPath, extra: profileData);
                    if (result == true) {
                      setState(() { _profileFuture = _fetchMyProfile(); });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0FFDD),
                    foregroundColor: const Color(0xFF388E3C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Edit information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

            // === NÚT ĐỔI MK VÀ ĐĂNG XUẤT (SỬA LẠI SPACING) ===
            if (!_isViewingOtherUser && !isAdmin) ...[

              const SizedBox(height: 12), // Khoảng cách

              // NÚT ĐỔI MẬT KHẨU (DÙNG TEXTBUTTON CHO MẤT VIỀN)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton( // <-- Đổi thành TextButton
                    onPressed: () {
                      showChangePasswordDialog(context);
                    },
                    style: TextButton.styleFrom( // <-- Đổi thành TextButton.styleFrom
                      foregroundColor: Colors.blue.shade800,
                      backgroundColor: Colors.blue.shade50, // Thêm nền nhạt cho nó "giống nút"
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Change password',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12), // Khoảng cách

              // NÚT ĐĂNG XUẤT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      fb_auth.FirebaseAuth.instance.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}