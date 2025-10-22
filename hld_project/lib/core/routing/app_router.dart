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

import '../../feature/Product/domain/usecase/createProduct.dart';
import '../../feature/Product/domain/usecase/updateProduct.dart';
import '../../feature/Product/domain/usecase/deleteProduct.dart';
import '../../feature/Product/domain/usecase/getProductById.dart';
import '../../feature/Product/domain/usecase/getProduct.dart';
import '../../feature/Product/data/datasource/product_repository_datasource.dart';
import '../../feature/Product/data/repositories/product_repository_impl.dart';

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
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,

    routes: [
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.signup, builder: (context, state) => const SignupPage()),

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
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state){
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
            }
            ,
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
      if (loggedIn && loggingIn) return AppRoutes.home;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
  );
}