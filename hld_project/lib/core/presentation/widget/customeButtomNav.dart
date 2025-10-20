import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.onItemTapped,
    required this.selectedIndex, // Đã đổi tên
  });
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex, // Sử dụng tên đã sửa
      onTap: onItemTapped,         // Sử dụng tên đã sửa
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true, // Thường dùng để hiển thị nhãn cho tất cả các mục
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Iconsax.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.user),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.message),
          label: 'Chat',
        ),
      ],
    );
  }
}