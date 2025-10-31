import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hld_project/feature/Account/presentation/pages/profile_page.dart';

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
import 'package:iconsax/iconsax.dart';

import '../../feature/Account/domain/entities/account.dart';
import '../../feature/Account/presentation/pages/profile_edit_page.dart';
import '../../feature/auth/presentation/providers/auth_provider.dart';
import '../navbar/domain/entity/bottom_nav_item.dart';
import '../navbar/presentation/widget/app_shell.dart';
import 'app_routers.dart';
import '../presentation/widget/customeButtomNav.dart';





class AppRouter {
  final AuthProvider authProvider;
  AppRouter(this.authProvider);

  // --- 4. ĐỊNH NGHĨA DANH SÁCH TABS CHO MỖI VAI TRÒ ---
  // (Dựa trên ảnh figma của bạn)
  static const List<BottomNavItem> _adminTabs = [
    BottomNavItem(path: '/admin/home', label: 'Home', icon: Iconsax.home_1),
    BottomNavItem(path: '/admin/product', label: 'Product', icon: Iconsax.box),
    BottomNavItem(path: '/admin/Pharmacy', label: 'Pharmacy', icon: Iconsax.danger),
    BottomNavItem(path: '/admin/account', label: 'Account', icon: Iconsax.user),
    BottomNavItem(path: '/admin/setting', label: 'Setting', icon: Iconsax.setting),
  ];

  // (Dựa trên yêu cầu 4 tab của bạn)
  static const List<BottomNavItem> _userTabs = [
    BottomNavItem(path: '/user/home', label: 'Home', icon: Iconsax.home_1),
    BottomNavItem(path: '/user/product', label: 'Product', icon: Iconsax.box),
    BottomNavItem(path: '/user/Pharmacy', label: 'Pharmacy', icon: Iconsax.danger),
    BottomNavItem(path: '/user/account', label: 'Account', icon: Iconsax.user),
  ];


  // --- 5. GO ROUTER INSTANCE (KHÔNG CÒN STATIC) ---
  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login, // Luôn bắt đầu từ Splash
    debugLogDiagnostics: true,
    refreshListenable: authProvider,

    // --- 6. LOGIC REDIRECT "CẢNH SÁT" HOÀN CHỈNH ---
    redirect: (context, state) {
      final bool isLoggedIn = authProvider.isLoggedIn;
      final bool isAdmin = authProvider.isAdmin;
      final location = state.matchedLocation;

      // Xác định các luồng "đặc biệt"
      final bool isAuthFlow = (location == AppRoutes.login ||
          location == AppRoutes.signup ||
          location == AppRoutes.home);
      final bool isGoingToAdmin = location.startsWith('/admin');
      final bool isGoingToUser = location.startsWith('/user');

      // 1. Chưa đăng nhập
      if (!isLoggedIn && !isAuthFlow) {
        return AppRoutes.login;
      }

      // 2. Đã đăng nhập
      if (isLoggedIn) {
        // Nếu đã đăng nhập mà cố vào trang auth (Login, Signup, Splash)
        if (isAuthFlow) {
          // Đẩy về trang chủ tương ứng
          return isAdmin ? '/admin/home' : '/user/home';
        }

        // 3. Logic PHÂN QUYỀN (NGĂN CHẶN CHÉO)
        // Nếu là Admin nhưng đang lạc vào luồng /user
        if (isAdmin && !isGoingToAdmin) {
          return '/admin/home'; // Kéo về trang chủ Admin
        }

        // Nếu là User nhưng đang lạc vào luồng /admin
        if (!isAdmin && !isGoingToUser) {
          return '/user/home'; // Kéo về trang chủ User
        }
      }

      // 4. Cho phép đi
      return null;
    },

    // --- 7. ROUTES VỚI HAI SHELLROUTE (DÙNG APP SHELL TÁI SỬ DỤNG) ---
    routes: [
      // Các route không có Shell
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.signup, builder: (context, state) => const SignupPage()),

      // --- SHELLROUTE CỦA ADMIN ---
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(
            tabs: _adminTabs,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/admin/home',
            builder: (context, state) => const AdminHomePage(),
          ),
          GoRoute(
            path: '/admin/product',
            // --- 5. TIÊM DI TRỞ LẠI (CHO ADMIN) ---
            builder: (context, state) {
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
          GoRoute(
            path: '/admin/Pharmacy',
            builder: (context, state) => Text("Pharmacy"),
          ),
          GoRoute(
            path: '/admin/account',
            builder: (context, state) => const ProfilePage(),
            routes: [
              // === THÊM ROUTE CHO PROFILE EDIT PAGE VÀO ĐÂY ===
              GoRoute(
                path: 'edit', // Đường dẫn sẽ là /user/account/edit
                builder: (context, state) {
                  // === SỬA DÒNG NÀY: ÉP KIỂU THẲNG SANG ACCOUNT ===
                  final Map<String, dynamic> initialData = state.extra as Map<String, dynamic>;
                  return ProfileEditPage(
                    initialData: initialData, // <-- TRUYỀN ĐÚNG TÊN THAM SỐ
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/admin/setting',
            builder: (context, state) => Text("Setting"),
          ),
        ],
      ),

      // --- SHELLROUTE CỦA USER ---
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(
            tabs: _userTabs,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/user/home',
            builder: (context, state) => HomePage(),
          ),
          GoRoute(
            path: '/user/product',
            // --- 6. TIÊM DI TRỞ LẠI (CHO USER) ---
            builder: (context, state) {
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
          GoRoute(
            path: '/user/Pharmacy',
            builder: (context, state) => Text("Pharmacy"),
          ),
          GoRoute(
            path: '/user/account',
            builder: (context, state) => const ProfilePage(),
            routes: [
              // === THÊM ROUTE CHO PROFILE EDIT PAGE VÀO ĐÂY ===
              GoRoute(
                path: 'edit', // Đường dẫn sẽ là /user/account/edit
                builder: (context, state) {
                  // === SỬA DÒNG NÀY: ÉP KIỂU THẲNG SANG ACCOUNT ===
                  final Map<String, dynamic> initialData = state.extra as Map<String, dynamic>;
                  return ProfileEditPage(
                    initialData: initialData, // <-- TRUYỀN ĐÚNG TÊN THAM SỐ
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

// --- CÁC HÀM STATIC HELPER ĐÃ BỊ XÓA ---
// (Đã xóa _getIndexForLocation và _getTitleForIndex)
// Logic này đã được chuyển vào bên trong 'AppShell'
}