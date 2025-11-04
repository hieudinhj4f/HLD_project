import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';

import '../../Account/presentation/pages/changePassword.dart';
import '../../Account/presentation/pages/profile_page.dart';

// --- ĐỊNH NGHĨA MÀU SẮC (Lấy từ Figma của bạn) ---
const Color settingPrimaryGreen = Color(0xFF4CAF50); // Màu xanh lá chính
const Color settingEmailGrey = Color(0xFF00C853); // Màu email (nhạt hơn)
const Color settingTileBg = Color(0xFFF5F5F5); // Màu nền của các ô
const Color settingIconGrey = Color(0xFF757575); // Màu icon

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Biến tạm để quản lý trạng thái của Theme Mode
  bool _isThemeDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'HLD',
          style: GoogleFonts.montserrat( // <-- Đổi thành GoogleFonts.tên_font
            fontWeight: FontWeight.w800, // Đây là độ dày Black (siêu dày)
            color: Colors.green,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 2. THÔNG TIN USER
            const _UserInfoHeader(
              name: 'Nguyen Dinh Hieu',
              email: 'dinhhieunguyen111@gmail.com',
              // imageUrl: '...' (Bạn có thể thêm URL ảnh)
            ),
            const SizedBox(height: 30),

            // 3. NHÓM TÙY CHỌN 1
            _SettingsTile(
              icon: Iconsax.edit,
              title: 'THÔNG TIN CÁ NHÂN',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            _SettingsTile(
              icon: Iconsax.moon,
              title: 'CHẾ ĐỘ TỐI',
              // Dùng 'trailing' để thêm nút Switch
              trailing: Switch(
                value: _isThemeDark,
                onChanged: (value) {
                  setState(() {
                    _isThemeDark = value;
                    // TODO: Gọi Provider/Service để đổi theme
                  });
                },
                activeColor: settingPrimaryGreen,
              ),
              onTap: null, // Không cần onTap vì đã có Switch
            ),
            _SettingsTile(
              icon: Iconsax.lock,
              title: 'ĐỔI MẬT KHẨU',
              onTap: () {
                showChangePasswordDialog(context);
              },
            ),

            const SizedBox(height: 30),

            // 4. NÚT LOG OUT
            _SettingsTile(
              icon: Iconsax.logout,
              title: 'ĐĂNG XUẤT',
              // Thêm màu đỏ cho nút Log Out
              iconColor: Colors.red[600],
              textColor: Colors.red[600],
              hideArrow: true, // Ẩn mũi tên
              onTap: () {
                final authProvider = context.read<AuthProvider>();
                authProvider.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET CON: Thông tin User ở trên ---
class _UserInfoHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? imageUrl;

  const _UserInfoHeader({
    required this.name,
    required this.email,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.grey[200], // Màu nền nếu không có ảnh
          backgroundImage: (imageUrl != null) ? NetworkImage(imageUrl!) : null,
          child: (imageUrl == null)
              ? const Icon(
            Iconsax.user,
            size: 50,
            color: Colors.grey,
          )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(
            fontSize: 14,
            color: settingEmailGrey,
          ),
        ),
      ],
    );
  }
}

// --- WIDGET CON: Một hàng tùy chọn ---
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;
  final bool hideArrow;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.textColor,
    this.hideArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: settingTileBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // Icon bên trái
        leading: Icon(
          icon,
          color: iconColor ?? settingIconGrey,
        ),
        // Tiêu đề
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        // Widget bên phải (Nút switch hoặc mũi tên)
        trailing: (trailing != null)
            ? trailing // Ưu tiên widget 'trailing' (cho nút Switch)
            : (hideArrow)
            ? null // Ẩn mũi tên (cho Log Out)
            : const Icon(
          Iconsax.arrow_right_3,
          color: settingIconGrey,
          size: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}