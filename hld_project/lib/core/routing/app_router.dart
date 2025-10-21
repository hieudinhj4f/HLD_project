import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hld_project/feature/Home/presentation/pages/home_page.dart';
import 'package:hld_project/feature/Product/presentation/pages/product_list_page.dart';
import '../../feature/Home/presentation/pages/splash_screen.dart';
import '../../feature/auth/presentation/pages/signup_page.dart';
import '../presentation/widget/customeButtomNav.dart';
import '../routing/app_routers.dart';
import '../../feature/auth/presentation/pages/login_page.dart';
import 'go_router_refresh_change.dart';

class AppGoRouter {
  // 1. HOÀN THIỆN HÀM TÍNH TOÁN INDEX
  static int _getIndexForLocation(String path) {
    if (path.startsWith(AppRoutes.home)) return 0;
    else if (path.startsWith(AppRoutes.profile)) return 1;
    else if (path.startsWith(AppRoutes.chat)) return 2;
    else if (path.startsWith(AppRoutes.account)) return 3;
    return 0; // Mặc định là Home
  }

  static final GoRouter router = GoRouter(
    // ... Khởi tạo và Routes độc lập (đã đúng)
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,

    routes: [
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.signup, builder: (context, state) => const SignupPage()),

      // LƯU Ý: Các tuyến độc lập này (HomePage, StudentListPage) sẽ không có BottomNav
      // và sẽ bị ShellRoute ghi đè nếu bạn dùng lại path bên trong ShellRoute.
      // Tốt nhất là BỎ CHÚNG ĐI, hoặc đổi tên và CHỈ SỬ DỤNG ShellRoute.
      // Tôi sẽ BỎ CHÚNG ở đây để tránh trùng lặp.
      // GoRoute(path: AppRoutes.home, builder: (context, state) => const HomePage()),

      // =========================================================================
      // SHELL ROUTE CÓ BOTTOM NAV (Đã hoàn thiện)
      // =========================================================================
      ShellRoute(
        builder: (context, state, child) {
          final currentIndex = _getIndexForLocation(state.matchedLocation);
          return Scaffold(
              appBar: AppBar(
              ),
              body: child,
              bottomNavigationBar: CustomBottomNav(
                  selectedIndex: currentIndex,
                  onItemTapped: (index) {
                    // 2. HOÀN THIỆN LOGIC ĐIỀU HƯỚNG BOTTOM NAV
                    if (index == 0) {
                      context.go(AppRoutes.home);
                    } else if (index == 1) {
                      context.go(AppRoutes.profile);
                    } else if (index == 2) {
                      context.go(AppRoutes.chat);
                    } else if (index == 3) {
                      context.go(AppRoutes.account);
                    }
                  }
              )
          );
        },
        routes: [
          // 3. HOÀN THIỆN CÁC TUYẾN CON CỦA SHELLROUTE
          GoRoute(
            path: AppRoutes.home,
            // Giả định HomePage (hoặc HomeScreen) là màn hình chính của tab 0
            builder: (context, state) => const ProductListPage(),
          ),
          // GoRoute(
          //   path: AppRoutes.profile,
          //   builder: (context, state) => const ProfileScreen(), // Màn hình cho tab 1
          // ),
          // GoRoute(
          //   path: AppRoutes.chat,
          //   builder: (context, state) => const ChatScreen(), // Màn hình cho tab 2
          // ),
          // GoRoute(
          //   path: AppRoutes.account,
          //   builder: (context, state) => const AccountScreen(), // Màn hình cho tab 3
          // ),

          // Tuyến ProductListPage (Nếu cần, nó không nằm trong Bottom Nav)
          // GoRoute(
          //   path: AppRoutes.product,
          //   builder: (context, state) => const ProductListPage(),
          // ),
        ],
      ),
    ],

    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final bool loggedIn = user != null;

      final bool loggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;

      if (!loggedIn && !loggingIn) return AppRoutes.login;
      // Chuyển hướng đến AppRoutes.home (tức là ShellRoute) sau khi đăng nhập
      if (loggedIn && loggingIn) return AppRoutes.home;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
  );
}