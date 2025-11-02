// === 1. IMPORT CỦA FLUTTER ===
import 'package:flutter/material.dart';

// === 2. IMPORT CỦA CÁC GÓI BÊN THỨ BA (3RD PARTY PACKAGES) ===
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

// === 3. IMPORT TỪ CÁC FEATURE KHÁC TRONG DỰ ÁN (PROJECT IMPORTS) ===

// Account
import 'package:hld_project/feature/Account/presentation/pages/account_list_page.dart';
import 'package:hld_project/feature/Account/presentation/pages/profile_page.dart';

// Auth
import 'package:hld_project/feature/auth/presentation/pages/login_page.dart';
import 'package:hld_project/feature/auth/presentation/pages/signup_page.dart';

// Chat & Doctor
import 'package:hld_project/feature/chat/domain/repositories/doctor_repository.dart';
import 'package:hld_project/feature/chat/domain/usecases/create_doctor.dart';
import 'package:hld_project/feature/chat/domain/usecases/delete_doctor.dart';
import 'package:hld_project/feature/chat/domain/usecases/update_doctor.dart';
import 'package:hld_project/feature/chat/presentation/pages/chat_home_page.dart';

// Dashboard
import 'package:hld_project/feature/Dashboard/presentation/pages/Dashboard.dart';

// Home
import 'package:hld_project/feature/Home/presentation/pages/home_page.dart';
import 'package:hld_project/feature/Home/presentation/pages/splash_screen.dart';

// Pharmacy
import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/createPharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/deletePharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/getAllPharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/updatePharmacy.dart';

// Product (DI & Usecases)
import 'package:hld_project/feature/Product/data/datasource/product_repository_datasource.dart';
import 'package:hld_project/feature/Product/data/repositories/product_repository_impl.dart';
import 'package:hld_project/feature/Product/domain/usecase/createProduct.dart';
import 'package:hld_project/feature/Product/domain/usecase/deleteProduct.dart';
import 'package:hld_project/feature/Product/domain/usecase/getProduct.dart';
import 'package:hld_project/feature/Product/domain/usecase/updateProduct.dart';

// Product (Pages - Tách biệt Admin và Setting)
import 'package:hld_project/feature/Product/presentation/Admin/pages/product_list_page.dart'
as admin_role; // <-- Dùng cho vai trò Admin
import 'package:hld_project/feature/Product/presentation/User/pages/cart_page.dart';
import 'package:hld_project/feature/Product/presentation/User/pages/invoice_page.dart';
import 'package:hld_project/feature/Product/presentation/User/pages/product_list_page.dart'
as user_role; // <-- Dùng cho vai trò Setting
import 'package:hld_project/feature/Product/presentation/User/pages/qr_payment_page.dart';
import 'package:hld_project/feature/chat/presentation/pages/doctor_list_page.dart';


// === 4. IMPORT TƯƠNG ĐỐI (RELATIVE IMPORTS - TỪ CHÍNH MODULE HIỆN TẠI) ===

// Imports từ các feature gần (../../)
import '../../feature/Account/domain/entities/account.dart';
import '../../feature/Account/presentation/pages/profile_edit_page.dart';
import '../../feature/Configuration/presentation/configuration_page.dart';
import '../../feature/Pharmacy/data/datasource/pharmacy_remote_datasource.dart';
import '../../feature/Pharmacy/data/repository/pharmacy_repository_impl.dart';
import '../../feature/Pharmacy/presentation/pages/pharmacy_list_page.dart';
import '../../feature/auth/presentation/providers/auth_provider.dart';
import '../../feature/chat/data/datasources/chat_remote_datasource.dart';
import '../../feature/chat/data/datasources/doctor_remote_datasource.dart';
import '../../feature/chat/data/repositories/chat_repository_impl.dart';
import '../../feature/chat/data/repositories/doctor_repository_impl.dart';
import '../../feature/chat/domain/usecases/get_all_doctor.dart';
import '../../feature/chat/domain/usecases/get_doctors.dart';

// Imports từ các file ngang cấp (../)
import '../navbar/domain/entity/bottom_nav_item.dart';
import '../navbar/presentation/widget/app_shell.dart';

// Imports từ file trong cùng thư mục (.)
import 'app_routers.dart';

class AppRouter {
  final AuthProvider authProvider;
  AppRouter(this.authProvider);

  static const List<BottomNavItem> _adminTabs = [
    BottomNavItem(path: '/admin/home', label: 'Home', icon: Icons.home),
    BottomNavItem(path: '/admin/product', label: 'Product', icon: Icons.shopping_cart),
    BottomNavItem(path: '/admin/Pharmacy', label: 'Pharmacy', icon: Icons.local_pharmacy ),
    BottomNavItem(path: '/admin/doctors', label: 'Doctors' , icon: Icons.person_2),
    BottomNavItem(path: '/admin/account', label: 'Account', icon: Icons.person),
    BottomNavItem(path: '/admin/setting', label: 'Setting', icon: Icons.settings),
  ];

  static const List<BottomNavItem> _userTabs = [
    BottomNavItem(path: '/user/product', label: 'Product', icon: Icons.home),
    BottomNavItem(path: '/user/cart', label: 'Cart', icon: Icons.shopping_cart),
    BottomNavItem(path: '/user/chat', label: 'Chat',icon: Icons.message),
    BottomNavItem(path: '/user/account', label: 'Account', icon: Icons.person),
  ];

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    refreshListenable: authProvider,

    redirect: (context, state) {
      final bool isLoggedIn = authProvider.isLoggedIn;
      final bool isAdmin = authProvider.isAdmin;
      final location = state.matchedLocation;

      final bool isAuthFlow =
          location == AppRoutes.login ||
          location == AppRoutes.signup ||
          location == AppRoutes.home;

      final bool isGoingToAdmin = location.startsWith('/admin');
      final bool isGoingToUser = location.startsWith('/user');

      if (!isLoggedIn && !isAuthFlow) return AppRoutes.login;
      if (isLoggedIn) {
        if (isAuthFlow) return isAdmin ? '/admin/home' : '/user/product';
        if (isAdmin && !isGoingToAdmin) return '/admin/home';
        if (!isAdmin && !isGoingToUser) return '/user/product';
      }
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupPage(),
      ),

      // ADMIN SHELL
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(tabs: _adminTabs, child: child),
        routes: [
          GoRoute(
            path: '/admin/home',
            builder: (context, state) =>
                AdminHomePage(), // ĐÃ SỬA: const + import đúng
          ),
          GoRoute(
            path: '/admin/product',
            builder: (context, state) {
              final remote = ProductRemoteDataSourceImpl();
              final repo = ProductRepositoryImpl(remote);
              return admin_role.ProductListPage(
                getProducts: GetAllProduct(repo),
                createProduct: CreateProduct(repo),
                updateProduct: UpdateProduct(repo),
                deleteProduct: DeleteProduct(repo),
              );
            },
          ),
          GoRoute(
            path: '/admin/Pharmacy',
            builder: (context, state) {
              final remote = PharmacyRemoteDataSourceImpl();
              final repo = PharmacyRepositoryImpl(remote);
              return PharmacyListPage(
                getAllPharmacies: GetAllPharmacy(repo),
                createPharmacy: CreatePharmacy(repo),
                updatePharmacy: UpdatePharmacy(repo),
                deletePharmacy: DeletePharmacy(repo),
              );
            },
          ),
          GoRoute(
            path: '/admin/account',
            builder: (context, state) => const AccountListPage(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => ProfileEditPage(
                  initialData: state.extra as Map<String, dynamic>,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/setting',
            builder: (context, state) => SettingsPage(),
          ),
          GoRoute(
            path: '/admin/doctors',
            builder: (content , state ) {
              final remote = DoctorRemoteDataSourceImpl();
              final repo = DoctorRepositoryImpl(remote);
              return DoctorListPage(
                getAllDoctors: GetAllDoctor(repo),
                createDoctor:  CreateDoctor(repo),
                updateDoctor:  UpdateDoctor(repo),
                deleteDoctor: DeleteDoctor(repo),
              );
            }
          )
        ],
      ),

      // USER SHELL
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(tabs: _userTabs, child: child),
        routes: [
          GoRoute(
            path: '/user/product',
            builder: (context, state) {
              final remote = ProductRemoteDataSourceImpl();
              final repo = ProductRepositoryImpl(remote);
              return user_role.ProductListPage(
                getProducts: GetAllProduct(repo),
                createProduct: CreateProduct(repo),
                updateProduct: UpdateProduct(repo),
                deleteProduct: DeleteProduct(repo),
              );
            },
          ),
          GoRoute(
            path: '/user/cart',
            builder: (context, state) => const CartPage(),
            routes: [
              GoRoute(
                path: 'qr-payment',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  return QRPaymentPage(
                    totalAmount: extra['totalAmount'] as double,
                    orderNumber: extra['orderNumber'] as String,
                  );
                },
              ),
              GoRoute(
                path: 'invoice',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  return InvoicePage(
                    totalAmount: extra['totalAmount'] as double,
                    orderNumber: extra['orderNumber'] as String,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/user/chat',
            builder: (context, state) {
              final remote = ChatRemoteDataSourceImpl();
              final repo = ChatRepositoryImpl(remote);
              return ChatHomePage(getDoctors: GetDoctors(repo));
            },

          ),
          GoRoute(
            path: '/user/account',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => ProfileEditPage(
                  initialData: state.extra as Map<String, dynamic>,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
