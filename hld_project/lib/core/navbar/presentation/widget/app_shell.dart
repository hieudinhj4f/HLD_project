import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/widget/customeButtomNav.dart';
import '../../domain/entity/bottom_nav_item.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Thêm nếu bạn muốn dùng nút logout

// 1. SỬA LỖI CÚ PHÁP: Đổi thành StatelessWidget
class AppShell extends StatelessWidget {
  final Widget child;
  final List<BottomNavItem> tabs;

  const AppShell({
    Key? key,
    required this.child,
    required this.tabs,
  }) : super(key: key);

  // Hàm tìm kiếm đường dẫn (vẫn hoạt động tốt)
  int _caculateCurrentIndex(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final String location = state.uri.toString();
    int index = tabs.indexWhere((tab) => location.startsWith(tab.path));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _caculateCurrentIndex(context);
    final String currentTitle = tabs[currentIndex].label;

    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: currentIndex,
        onItemTapped: (index) {
          context.go(tabs[index].path);
        },

        // 2. KẾT NỐI:
        // Bỏ comment và truyền 'tabs' (4 hoặc 5)
        // vào thuộc tính 'items' mới của CustomBottomNav
        items: tabs,
      ),
    );
  }
}