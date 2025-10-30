// file: lib/feature/Account/presentation/pages/profile_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';

import '../../data/model/account_model.dart';
import '../../domain/entities/account.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  // ===== HÀM LOGIC TỰ LẤY DATA (KHÔNG QUA PROVIDER) =====
  Future<Account> _fetchMyProfile() async {
    // 1. Tự lấy UID từ FirebaseAuth
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('Bạn chưa đăng nhập!');
    }

    try {
      // 2. Tự gọi Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users') // Tên collection (ảnh mày gửi)
          .doc(uid)
          .get();

      if (doc.exists) {
        // 3. Tự parse (dùng hàm fromFirestore của Model)
        return AccountModel.fromFirestore(doc);
      } else {
        throw Exception('Không tìm thấy thông tin profile.');
      }
    } catch (e) {
      // 4. Báo lỗi
      throw Exception('Lỗi khi tải profile: ${e.toString()}');
    }
  }

  // Hàm helper để check null/rỗng
  String _displayValue(String value) {
    return value.isEmpty ? 'Chưa cập nhật' : value;
  }

  @override
  Widget build(BuildContext context) {
    // 3. DÙNG FUTUREBUILDER (THAY VÌ context.watch)
    return Scaffold(
      // (AppBar có thể được cung cấp bởi ShellRoute của mày)
      body: FutureBuilder<Account>(
        future: _fetchMyProfile(), // Gọi hàm "bẩn" ở trên
        builder: (context, snapshot) {

          // === TRẠNG THÁI 1: ĐANG TẢI ===
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // === TRẠNG THÁI 2: BỊ LỖI ===
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          // === TRẠNG THÁI 3: KHÔNG CÓ DATA (hiếm) ===
          if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy dữ liệu.'));
          }

          // === TRẠNG THÁI 4: CÓ DATA (OK) ===
          final Account user = snapshot.data!; // Lấy data

          // Đây là UI cũ của mày, giờ nó dùng 'user' từ FutureBuilder
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Thông tin
                InfoTile(label: 'Họ và tên', value: _displayValue(user.name)),
                InfoTile(label: 'Email', value: _displayValue(user.email)),
                InfoTile(label: 'Số điện thoại', value: _displayValue(user.phone)),
                InfoTile(label: 'Giới tính', value: _displayValue(user.gender)),
                InfoTile(label: 'Ngày sinh (dob)', value: _displayValue(user.dob)),
                InfoTile(label: 'Tuổi (age)', value: _displayValue(user.age)),
                InfoTile(label: 'Địa chỉ (address)', value: _displayValue(user.address)),

                const SizedBox(height: 32),

                // Nút Chỉnh sửa
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade900,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Mở trang Chỉnh sửa
                  },
                  child: const Text('Chỉnh sửa thông tin'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==============================================
// WIDGET PHỤ (Mày phải có cái này)
// ==============================================
class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const InfoTile({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}