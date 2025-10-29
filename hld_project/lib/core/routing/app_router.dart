import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 1. IMPORT AUTH PROVIDER

// --- Imports cho các Pages
import 'package:hld_project/feature/Home/presentation/pages/home_page.dart';
import 'package:hld_project/feature/Product/presentation/pages/product_list_page.dart';
import 'package:hld_project/feature/auth/presentation/pages/login_page.dart';
import 'package:hld_project/feature/auth/presentation/pages/signup_page.dart';
import 'package:hld_project/feature/Home/presentation/pages/splash_screen.dart';
// import 'package:hld_project/feature/admin/presentation/pages/admin_page.dart'; // <-- BẠN SẼ CẦN TRANG NÀY

// --- Imports cho DI (Tạm thời giữ nguyên)
import 'package:hld_project/feature/Product/data/datasource/product_repository_datasource.dart';
import 'package:hld_project/feature/Product/data/repositories/product_repository_impl.dart';
import 'package:hld_project/feature/Product/domain/usecase/createProduct.dart';
import 'package:hld_project/feature/Product/domain/usecase/updateProduct.dart';
import 'package:hld_project/feature/Product/domain/usecase/deleteProduct.dart';
import 'package:hld_project/feature/Product/domain/usecase/getProduct.dart';

import '../../feature/auth/presentation/providers/auth_provider.dart';
import 'app_routers.dart';
import '../presentation/widget/customeButtomNav.dart';


class AppRouter { // <-- ĐỔI TÊN (VÀ XÓA STATIC)

  // 2. BIẾN ĐỂ GIỮ AUTH PROVIDER
  final AuthProvider authProvider;

  // 3. CONSTRUCTOR ĐỂ NHẬN AUTH PROVIDER
  AppRouter(this.authProvider);

  // 4. ROUTER INSTANCE (KHÔNG CÒN STATIC)
  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login, // Nên bắt đầu từ Splash
    debugLogDiagnostics: true,

    // 5. SỬA LẠI REFRESHLISTENABLE
    // Lắng nghe AuthProvider, KHÔNG phải FirebaseAuth
    refreshListenable: authProvider,

    routes: [
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.signup, builder: (context, state) => const SignupPage()),

      // Giả sử bạn có 1 route Admin nằm ngoài ShellRoute
      GoRoute(
        path: '/admin', // ĐÂY LÀ ROUTE CẦN BẢO VỆ
        builder: (context, state) => const Text('Admin Page'), // Thay bằng AdminPage()
      ),

      ShellRoute(
        builder: (context, state, child) {
          final currentIndex = _getIndexForLocation(state.matchedLocation);
          return Scaffold(
              appBar: AppBar(
                title: Text(_getTitleForIndex(currentIndex)),
                // Thêm nút logout (tùy chọn)
                actions: [
                  if (currentIndex == 3) // Ví dụ: chỉ hiện ở tab Account
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                    )
                ],
              ),
              body: child,
              bottomNavigationBar: CustomBottomNav(
                  selectedIndex: currentIndex,
                  onItemTapped: (index) {
                    if (index == 0) context.go(AppRoutes.home);
                    else if (index == 1) context.go(AppRoutes.recipe);
                    else if (index == 2) context.go(AppRoutes.chat);
                    else if (index == 3) context.go(AppRoutes.account);
                  }));
        },
        routes: [
          // TAB 0: Product List
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) {
              // GÓP Ý: Phần DI này nên đưa ra ngoài
              late final remote = ProductRemoteDataSourceImpl();
              late final repo = ProductRepositoryImpl(remote);
              late final getProducts = GetAllProduct(repo);
              late final createProduct = CreateProduct(repo);
              late final updateProduct = UpdateProduct(repo);
              late final deleteProduct = DeleteProduct(repo);
              return ProductListPage(
                getProducts: getProducts,
                createProduct: createProduct,
                updateProduct: updateProduct,
                deleteProduct: deleteProduct,
              );
            },
          ),

          // TAB 1: Recipe
          GoRoute(
            path: AppRoutes.recipe,
            builder: (context, state) => const Center(child: Text("Recipe Page")),
          ),

          // TAB 2: Chat
          GoRoute(
            path: AppRoutes.chat,
            builder: (context, state) => const Center(child: Text("Chat Page")),
          ),

          // TAB 3: Account
          GoRoute(
            path: AppRoutes.account,
            builder: (context, state) => const Center(child: Text("Account Page")),
          ),
        ],
      ),
    ],

    // 6. SỬA LẠI REDIRECT ĐỂ CHECK ROLE (QUAN TRỌNG NHẤT)
    redirect: (context, state) {
      // Đọc trạng thái TỪ AUTHPROVIDER (không phải FirebaseAuth)
      final bool isLoggedIn = authProvider.isLoggedIn;
      final bool isAdmin = authProvider.isAdmin;

      final location = state.matchedLocation;
      final bool isAuthPage = (location == AppRoutes.login || location == AppRoutes.signup);

      // 1. Logic cho người chưa đăng nhập
      if (!isLoggedIn && !isAuthPage && location != AppRoutes.splash) {
        return AppRoutes.login; // Đá về login
      }

      // 2. Logic cho người đã đăng nhập
      if (isLoggedIn && (isAuthPage || location == AppRoutes.splash)) {
        return AppRoutes.home; // Đá về home
      }

      // 3. LOGIC PHÂN QUYỀN (BLOCK ADMIN PAGE)
      final bool isGoingToAdmin = location.startsWith('/admin');
      if (isLoggedIn && isGoingToAdmin && !isAdmin) {
        // Nếu là 'user' mà cố vào '/admin'
        return AppRoutes.home; // Đá về home
      }

      // 4. Cho phép đi
      return null;
    },
  );

  // --- Các hàm helper (giữ nguyên) ---
  static int _getIndexForLocation(String path) {
    if (path.startsWith(AppRoutes.home)) return 0;
    if (path.startsWith(AppRoutes.recipe)) return 1;
    if (path.startsWith(AppRoutes.chat)) return 2;
    if (path.startsWith(AppRoutes.account)) return 3;
    return 0;
  }
  static String _getTitleForIndex(int index) {
    // ... (giữ nguyên)
    switch (index) {
      case 0: return 'Sản phẩm (Product)';
      case 1: return 'Công thức (Recipe)';
      case 2: return 'Chat';
      case 3: return 'Tài khoản';
      default: return 'Trang chủ';
    }
  }
}