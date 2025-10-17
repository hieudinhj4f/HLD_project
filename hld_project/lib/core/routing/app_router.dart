import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../feature/Student/presentation/pages/student_list_page.dart';
import '../routing/app_routers.dart';
import '../../feature/auth/presentation/pages/login_page.dart';
import 'go_router_refresh_change.dart';

class AppGoRouter {
  static final GoRouter router = GoRouter(
    // Trang khởi đầu khi mở app
    initialLocation: AppRoutes.login,

    // Bật log để debug dễ hơn
    debugLogDiagnostics: true,

    routes: [
      /// =============== Auth routes ===============
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      // GoRoute(
      //   path: AppRoutes.signup,
      //   builder: (context, state) => const SignupPage(),
      // ),

      /// =============== Protected routes ===============
      /// Chỉ user đăng nhập mới truy cập được
      ShellRoute(
        /// Tạo khung giao diện chung (Scaffold)
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('CARLY Showroom - Student Manager'),
            ),
            body: child,
            // Nếu bạn có BottomNav, dùng ở đây
            // bottomNavigationBar: CustomBottomNav(),
          );
        },
        routes: [
          /// Màn hình chính (Student List)
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const StudentListPage(),
          ),
        ],
      ),
    ],

    /// =============== Redirect logic ===============
    /// Hàm này quyết định khi nào user bị điều hướng sang Login hoặc Home
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final bool loggedIn = user != null;

      final bool loggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;

      // Nếu chưa login mà lại vào trang yêu cầu đăng nhập → quay lại login
      if (!loggedIn && !loggingIn) return AppRoutes.login;

      // Nếu đã login mà vẫn ở trang login/signup → đưa về home
      if (loggedIn && loggingIn) return AppRoutes.home;

      // Ngược lại giữ nguyên
      return null;
    },

    /// =============== Theo dõi thay đổi trạng thái đăng nhập ===============
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
  );
}
