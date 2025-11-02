import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/widget/customeButtomNav.dart'; // Đảm bảo đúng đường dẫn
import '../../domain/entity/bottom_nav_item.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  final List<BottomNavItem> tabs;

  const AppShell({super.key, required this.child, required this.tabs});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndexFromLocation();
  }

  void _updateIndexFromLocation() {
    final location = GoRouterState.of(context).matchedLocation;
    final index = widget.tabs.indexWhere(
      (tab) => location.startsWith(tab.path),
    );
    if (index != -1 && index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  void _onTabTapped(int index) {
    final path = widget.tabs[index].path;
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _currentIndex,
        onItemTapped: _onTabTapped,
        items: widget.tabs, // Đảm bảo CustomBottomNav nhận đúng
      ),
    );
  }
}
