import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hld_project/feature/Account/presentation/pages/profile_page.dart';

// 1. IMPORT AUTH PROVIDER

// --- Imports cho các Pages
import 'package:hld_project/feature/Home/presentation/pages/home_page.dart';
import 'package:hld_project/feature/Product/presentation/Admin/pages/product_list_page.dart';
import 'package:hld_project/feature/Product/presentation/User/pages/cart_page.dart';
import 'package:hld_project/feature/auth/presentation/pages/login_page.dart';
import 'package:hld_project/feature/auth/presentation/pages/signup_page.dart';
import 'package:hld_project/feature/Home/presentation/pages/splash_screen.dart';
// import 'package:hld_project/feature/admin/presentation/pages/admin_page.dart'; // <-- BẠN SẼ CẦN TRANG NÀY


import 'package:hld_project/feature/Product/data/datasource/product_repository_datasource.dart';
import 'package:hld_project/feature/Product/data/repositories/product_repository_impl.dart';
import 'package:hld_project/feature/Product/domain/usecase/createProduct.dart';
import 'package:hld_project/feature/Product/domain/usecase/updateProduct.dart';
import 'package:hld_project/feature/Product/domain/usecase/deleteProduct.dart';
import 'package:hld_project/feature/Product/domain/usecase/getProduct.dart';
// --- Imports cho DI ( Cho product - admin )
import 'package:hld_project/feature/Product/presentation/Admin/pages/product_list_page.dart' as admin_role;
// --- Imports cho DI ( Cho product - user )
import 'package:hld_project/feature/Product/presentation/User/pages/product_list_page.dart' as user_role;
import 'package:iconsax/iconsax.dart';

// --- Imports cho DI (Tạm thời giữ nguyên)
import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/createPharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/deletePharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/updatePharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/getAllPharmacy.dart';
import 'package:iconsax/iconsax.dart';

import '../../feature/Account/domain/entities/account.dart';
import '../../feature/Account/presentation/pages/profile_edit_page.dart';
import '../../feature/Dashboard/presentation/pages/Dashboard.dart';
import '../../feature/Pharmacy/data/datasource/pharmacy_remote_datasource.dart';
import '../../feature/Pharmacy/data/repository/pharmacy_repository_impl.dart';
import '../../feature/Pharmacy/presentation/pages/pharmacy_list_page.dart';
import '../../feature/auth/presentation/providers/auth_provider.dart';
import '../navbar/domain/entity/bottom_nav_item.dart';
import '../navbar/presentation/widget/app_shell.dart';
import 'app_routers.dart';
import '../presentation/widget/customeButtomNav.dart';





class AppRouter {
  final AuthProvider authProvider;
  AppRouter(this.authProvider);

  // --- 4. ĐỊNH NGHĨA DANH SÁCH TABS CHO MỖI VAI TRÒ ---
  static const List<BottomNavItem> _adminTabs = [
    BottomNavItem(path: '/admin/home', label: 'Home', icon: Iconsax.home_1),
    BottomNavItem(path: '/admin/product', label: 'Product', icon: Iconsax.shopping_cart),
    // Tên path '/admin/Pharmacy' phải khớp với GoRoute
    BottomNavItem(path: '/admin/Pharmacy', label: 'Pharmacy', icon: Iconsax.danger),
    BottomNavItem(path: '/admin/account', label: 'Account', icon: Iconsax.user),
    BottomNavItem(path: '/admin/setting', label: 'Setting', icon: Iconsax.setting),
  ];

  static const List<BottomNavItem> _userTabs = [
    BottomNavItem(path: '/user/product', label: 'product', icon: Iconsax.home_1),
    BottomNavItem(path: '/user/cart', label: 'cart', icon: Iconsax.shopping_cart),
    // Tên path '/user/Pharmacy' phải khớp với GoRoute
    BottomNavItem(path: '/user/Pharmacy', label: 'Pharmacy', icon: Iconsax.danger),
    BottomNavItem(path: '/user/account', label: 'Account', icon: Iconsax.user),
  ];

  // --- 5. GO ROUTER INSTANCE (KHÔNG CÒN STATIC) ---
  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    refreshListenable: authProvider,

    // --- 6. LOGIC REDIRECT "CẢNH SÁT" HOÀN CHỈNH ---
    redirect: (context, state) {
      // ... (Phần redirect của bạn đã ổn, giữ nguyên) ...
      final bool isLoggedIn = authProvider.isLoggedIn;
      final bool isAdmin = authProvider.isAdmin;
      final location = state.matchedLocation;

      final bool isAuthFlow = (location == AppRoutes.login ||
          location == AppRoutes.signup ||
          location == AppRoutes.home);
      final bool isGoingToAdmin = location.startsWith('/admin');
      final bool isGoingToUser = location.startsWith('/user');

      if (!isLoggedIn && !isAuthFlow) {
        return AppRoutes.login;
      }

      if (isLoggedIn) {
        if (isAuthFlow) {
          return isAdmin ? '/admin/home' : '/user/product';
        }
        if (isAdmin && !isGoingToAdmin) {
          return '/admin/home';
        }
        if (!isAdmin && !isGoingToUser) {
          return '/user/product';
        }
      }
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
            builder: (context, state) {
              late final remote = ProductRemoteDataSourceImpl();
              // [SỬA] Thêm tên tham số 'remoteDatasource'
              late final repo = ProductRepositoryImpl(remote);
              late final getProducts = GetAllProduct(repo);
              late final createProduct = CreateProduct(repo);
              late final updateProduct = UpdateProduct(repo);
              late final deleteProduct = DeleteProduct(repo);
              return admin_role.ProductListPage(
                getProducts: getProducts,
                createProduct: createProduct,
                updateProduct: updateProduct,
                deleteProduct: deleteProduct,
              );
            },
          ),
          // --- (MỚI) ROUTE PHARMACY CỦA ADMIN VỚI DI ---
          GoRoute(
            path: '/admin/Pharmacy', // Phải khớp với 'path' trong _adminTabs
            builder: (context, state) {
              late final remote = PharmacyRemoteDataSourceImpl();
              late final repo = PharmacyRepositoryImpl(remote);
              late final getAllPharmacyy = GetAllPharmacy(repo);
              late final createPharmacy = CreatePharmacy(repo);
              late final updatePharmacy = UpdatePharmacy(repo);
              late final deletePharmacy = DeletePharmacy(repo);

              // Giả sử PharmacyListPage cũng cần 4 usecases này
              return PharmacyListPage(
                getAllPharmacies : getAllPharmacyy,
                createPharmacy: createPharmacy,
                updatePharmacy: updatePharmacy,
                deletePharmacy: deletePharmacy,
              );
            },
          ),
          GoRoute(
            path: '/admin/account',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final Map<String, dynamic> initialData = state.extra as Map<String, dynamic>;
                  return ProfileEditPage(
                    initialData: initialData,
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
            path: '/user/product',
            builder: (context, state) {
              late final remote = ProductRemoteDataSourceImpl();
              late final repo = ProductRepositoryImpl(remote);
              late final getProducts = GetAllProduct(repo);
              late final createProduct = CreateProduct(repo);
              late final updateProduct = UpdateProduct(repo);
              late final deleteProduct = DeleteProduct(repo);
              return user_role.ProductListPage(
                getProducts: getProducts,
                createProduct: createProduct,
                updateProduct: updateProduct,
                deleteProduct: deleteProduct,
              );
            },
          ),
          GoRoute(
            path: '/user/cart',
            builder: (context, state) => CartPage(),
          ),
          // --- (MỚI) ROUTE PHARMACY CỦA USER VỚI DI ---
          GoRoute(
            path: '/user/Pharmacy', // Phải khớp với 'path' trong _userTabs
            builder: (context, state) {
              // (Bạn lặp lại DI giống như admin,
              // theo đúng pattern bạn làm với Product)
              late final remote = PharmacyRemoteDataSourceImpl();
              late final repo = PharmacyRepositoryImpl(remote);
              late final getAllPharmacy = GetAllPharmacy(repo);
              late final createPharmacy = CreatePharmacy(repo);
              late final updatePharmacy = UpdatePharmacy(repo);
              late final deletePharmacy = DeletePharmacy(repo);

              return PharmacyListPage(
                getAllPharmacies: getAllPharmacy,
                createPharmacy: createPharmacy,
                updatePharmacy: updatePharmacy,
                deletePharmacy: deletePharmacy,
              );
            },
          ),
          // --- (HẾT MỚI) ---
          GoRoute(
            path: '/user/account',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final Map<String, dynamic> initialData = state.extra as Map<String, dynamic>;
                  return ProfileEditPage(
                    initialData: initialData,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}