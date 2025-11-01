import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../navbar/domain/entity/bottom_nav_item.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  // 2. THÊM THUỘC TÍNH NÀY
  // Nó sẽ nhận 4 tabs (từ UserShell) hoặc 5 tabs (từ AdminShell)
  final List<BottomNavItem> items;

  const CustomBottomNav({
    super.key,
    required this.onItemTapped,
    required this.selectedIndex,
    required this.items, // 3. YÊU CẦU TRUYỀN VÀO
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: Color(0xFF2DCC70),      // Giữ nguyên style của bạn
      unselectedItemColor: Colors.grey,     // Giữ nguyên style của bạn
      showUnselectedLabels: true,           // Giữ nguyên style của bạn
      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon), // Lấy icon từ model
          label: item.label,   // Lấy label từ model
        );
      }).toList(),
    );
  }
}