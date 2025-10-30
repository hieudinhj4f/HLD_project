// file: lib/feature/Account/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              user.name, // (name)
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // ===== SỬA LẠI CHO KHỚP ẢNH FIREBASE =====
            InfoTile(label: 'Họ và tên', value: user.name),
            InfoTile(
              label: 'Email',
              value: (user.email?.isEmpty ?? true) ? 'Chưa cập nhật' : user.email!,
            ),
            InfoTile(label: 'Số điện thoại', value: user.phone),
            InfoTile(label: 'Giới tính', value: user.gender),
            InfoTile(label: 'Ngày sinh (dob)', value: user.dob),
            // ===========================================

            const SizedBox(height: 32),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                // Mở trang Chỉnh sửa
              },
              child: const Text('Chỉnh sửa thông tin'),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget phụ InfoTile (giữ nguyên)
class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const InfoTile({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}