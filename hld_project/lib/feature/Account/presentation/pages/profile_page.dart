// file: lib/feature/Account/presentation/pages/profile_page.dart
// BẢN "THÔNG MINH" - TỰ XEM HOẶC XEM CỦA NGƯỜI KHÁC (ĐÃ SỬA LỖI RETURN)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

// === IMPORT AUTHPROVIDER ĐỂ CHECK ROLE ===
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';
// === IMPORT "BẨN" CHO NÚT XÓA ===
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';
import 'package:hld_project/feature/Account/data/repositories/account_repository_impl.dart';
import 'package:hld_project/feature/Account/domain/usecases/delete_account.dart';

import '../../data/model/account_model.dart';
import '../../domain/entities/account.dart';
import 'profile_edit_page.dart'; // Import trang Edit


// === 1. ĐỔI THÀNH STATEFULWIDGET ===
class ProfilePage extends StatefulWidget {
  // NHẬN ACCOUNT TÙY CHỌN (NẾU ADMIN GỌI "OPEN")
  final Account? account;

  const ProfilePage({Key? key, this.account}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Biến giữ Future (chỉ dùng nếu xem profile của chính mình)
  late Future<Account> _profileFuture;

  // Biến giữ Account (hoặc là của mình, hoặc là của người khác)
  Account? _userToDisplay;

  // Biến xác định xem đây là trang của mình hay của người khác
  bool _isViewingOtherUser = false;

  @override
  void initState() {
    super.initState();

    if (widget.account != null) {
      // TRƯỜNG HỢP 1: ADMIN BẤM "OPEN"
      // Dùng data được truyền vào
      _userToDisplay = widget.account;
      _isViewingOtherUser = true;
    } else {
      // TRƯỜNG HỢP 2: TỰ XEM PROFILE (USER/ADMIN TỪ BOTTOMNAV)
      // Dùng Future để tự fetch
      _profileFuture = _fetchMyProfile();
      _isViewingOtherUser = false;
    }
  }

  // === HÀM TỰ LẤY DATA (CHO TRƯỜNG HỢP 2) ===
  Future<Account> _fetchMyProfile() async {
    final String? uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Bạn chưa đăng nhập!');
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return AccountModel.fromFirestore(doc);
      } else {
        throw Exception('Không tìm thấy thông tin profile.');
      }
    } catch (e) {
      throw Exception('Lỗi khi tải profile: ${e.toString()}');
    }
  }

  // === HÀM XÓA (CHO TRƯỜNG HỢP 1 - ADMIN VIEW) ===
  Future<void> _deleteAccount(String accountId) async {
    // 1. Tự tạo UseCase "bẩn"
    final dataSource = AccountRemoteDatasourceIpml();
    final repository = AccountRepositoryImpl(remoteDataSource: dataSource);
    final deleteUseCase = DeleteAccount(repository);

    // 2. Hỏi xác nhận
    final confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa tài khoản này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('XÓA', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    // 3. Gọi UseCase và Pop(true)
    if (confirmed == true) {
      try {
        await deleteUseCase.call(accountId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa tài khoản thành công.')));
          context.pop(true); // Trả về 'true' để AccountListPage refresh
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
      }
    }
  }

  // Hàm helper (check null/rỗng)
  String _displayValue(String? value) {
    return (value == null || value.isEmpty) ? 'Chưa cập nhật' : value;
  }

  // === HÀM CHUYỂN ACCOUNT OBJECT THÀNH MAP<STRING, STRING> THỦ CÔNG ===
  Map<String, String> _createProfileMap(Account user) {
    // === SỬA LỖI: THÊM RETURN VÀO ĐÂY ===
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
      // Chuyển DateTime sang String ISO để xử lý
      'createAt': user.createAt.toIso8601String(),
      'updateAt': user.updateAt.toIso8601String(),
    };
  }

  // === WIDGET DÒNG TEXT PHẲNG ===
  Widget _buildTextField(String label, String value) {
    // === SỬA LỖI: THÊM RETURN VÀO ĐÂY ===
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // === LOGIC BUILD CHÍNH ===
    // Nếu không phải xem người khác (Trường hợp 2) -> dùng FutureBuilder
    if (!_isViewingOtherUser) {
      return Scaffold(
        appBar: _buildProfileAppBar(context, isAdmin: context.read<AuthProvider>().isAdmin),
        body: FutureBuilder<Account>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: Text('Không tìm thấy dữ liệu.'));

            final Account user = snapshot.data!;
            return _buildProfileBody(context, user, isAdmin: context.read<AuthProvider>().isAdmin);
          },
        ),
      );
    }

    // Nếu là xem người khác (Trường hợp 1) -> Dùng data đã có
    return Scaffold(
      appBar: _buildProfileAppBar(context, isAdmin: true), // Admin xem thì luôn là Admin
      body: _buildProfileBody(context, _userToDisplay!, isAdmin: true),
    );
  }


  // === TÁCH APPBAR RA CHO SẠCH ===
  AppBar _buildProfileAppBar(BuildContext context, {required bool isAdmin}) {
    return AppBar(
      // Nút back (chỉ hiện khi Admin xem)
      leading: _isViewingOtherUser
          ? IconButton(icon: const Icon(Iconsax.arrow_left, color: Colors.black), onPressed: () => context.pop())
          : null, // User tự xem thì không có nút back
      title: const Text('HLD Project', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      centerTitle: true,
      actions: [
        // Nút thông báo (chỉ hiện khi tự xem)
        if (!_isViewingOtherUser)
          IconButton(
            icon: const Icon(Iconsax.notification, color: Colors.black),
            onPressed: () {},
          ),
        // Nút Logout (chỉ hiện khi tự xem)
        if (!_isViewingOtherUser)
          IconButton(
            icon: const Icon(Iconsax.logout, color: Colors.black),
            onPressed: () {
              fb_auth.FirebaseAuth.instance.signOut();
            },
          ),
      ],
    );
  }

  // === TÁCH BODY UI RA CHO SẠCH ===
  Widget _buildProfileBody(BuildContext context, Account user, {required bool isAdmin}) {
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
              child: const Icon(Iconsax.user, size: 50, color: Colors.grey),
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5) ],
              ),
              child: Column(
                children: [
                  _buildTextField('Họ và tên', _displayValue(user.name)),
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                  _buildTextField('Số điện thoại', _displayValue(user.phone)),
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                  _buildTextField('Giới tính', _displayValue(user.gender)),
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                  _buildTextField('Ngày sinh', _displayValue(user.dob)),
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                  _buildTextField('Địa chỉ', _displayValue(user.address)),
                  // Admin xem thì thấy thêm Role
                  if (isAdmin) ...[
                    const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                    _buildTextField('Role', _displayValue(user.role)),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Nút Chỉnh sửa (nếu tự xem) HOẶC Nút Xóa (nếu Admin xem)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: _isViewingOtherUser
                // === NÚT XÓA (ADMIN XEM) ===
                    ? ElevatedButton(
                  onPressed: () => _deleteAccount(user.id), // Sửa: Thêm context
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Xóa Tài Khoản Này', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  child: const Text('Chỉnh sửa thông tin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}