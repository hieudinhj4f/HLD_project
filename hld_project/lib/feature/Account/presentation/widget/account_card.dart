// file: lib/feature/Account/widgets/account_card.dart
import 'package:flutter/material.dart';
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import 'package:iconsax/iconsax.dart'; // (Icon cho nó đẹp)

class AccountCard extends StatelessWidget {
  final Account account;

  // === SỬA LẠI THAM SỐ ===
  final bool isSelected; // <-- THÊM CÁI NÀY
  final VoidCallback onTap; // <-- THÊM CÁI NÀY
  // (BỎ onEdit và onDelete)

  const AccountCard({
    Key? key,
    required this.account,
    required this.isSelected, // <-- THÊM VÀO
    required this.onTap,      // <-- THÊM VÀO
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Dùng isSelected để đổi màu nền
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        // Thêm viền nếu được chọn
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap, // <-- GỌI HÀM NÀY KHI BẤM
        leading: CircleAvatar(
          backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
          foregroundColor: Colors.white,
          // (Mày có thể thêm avatar thật ở đây)
          child: Text(account.name.isNotEmpty ? account.name[0].toUpperCase() : '?'),
        ),
        title: Text(
          account.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(account.email ?? 'Không có email'),
        // Hiển thị icon role cho nó xịn
        trailing: Icon(
          account.role == 'admin' ? Iconsax.security_user : Iconsax.user,
          color: account.role == 'admin' ? Colors.blue : Colors.grey,
        ),
        // (BỎ 2 NÚT EDIT/DELETE VÌ NÓ ĐÃ CHUYỂN SANG PANEL PHẢI)
      ),
    );
  }
}