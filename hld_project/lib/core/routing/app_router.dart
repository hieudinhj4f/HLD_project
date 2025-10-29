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

// SỬA ĐÚNG ĐƯỜNG DẪN
import '../../feature/Product/data/datasources/product_remote_datasource.dart'; // ĐÃ SỬA
import '../../feature/Product/data/repositories/product_repository_impl.dart';
import '../../feature/Product/domain/usecase/getProduct.dart';
import '../../feature/Product/domain/usecase/createProduct.dart';
import '../../feature/Product/domain/usecase/updateProduct.dart';
import '../../feature/Product/domain/usecase/deleteProduct.dart';

import '../../feature/chat/data/datasources/chat_remote_datasource.dart';
import '../../feature/chat/data/repositories/chat_repository_impl.dart';
import '../../feature/chat/domain/usecases/get_doctors.dart';
import '../../feature/chat/presentation/pages/chat_home_page.dart';

import '../../feature/Product/presentation/pages/cart_page.dart';
import '../../feature/account/presentation/pages/account_page.dart';

class AppGoRouter {
  static int _getIndexForLocation(String path) {
    if (path.startsWith(AppRoutes.home))
      return 0;
    else if (path.startsWith(AppRoutes.cart))
      return 1;
    else if (path.startsWith(AppRoutes.chat))
      return 2;
    else if (path.startsWith(AppRoutes.account))
      return 3;
    return 0;
  }

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,

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

      ShellRoute(
        builder: (context, state, child) {
          final currentIndex = _getIndexForLocation(state.matchedLocation);
          return Scaffold(
            appBar: AppBar(),
            body: child,
            bottomNavigationBar: CustomBottomNav(
              selectedIndex: currentIndex,
              onItemTapped: (index) {
                if (index == 0)
                  context.go(AppRoutes.home);
                else if (index == 1)
                  context.go(AppRoutes.cart);
                else if (index == 2)
                  context.go(AppRoutes.chat);
                else if (index == 3)
                  context.go(AppRoutes.account);
              },
            ),
          );
        },
        routes: [
          // HOME
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) {
              final remote = ProductRemoteDataSourceImpl();
              final repo = ProductRepositoryImpl(remote);
              return ProductListPage(
                getProducts: GetAllProduct(repo),
                createProduct: CreateProduct(repo),
                updateProduct: UpdateProduct(repo),
                deleteProduct: DeleteProduct(repo),
              );
            },
          ),
          // CART
          GoRoute(
            path: AppRoutes.cart,
            builder: (context, state) => const CartPage(),
          ),
          // CHAT
          GoRoute(
            path: AppRoutes.chat,
            builder: (context, state) {
              final remote = ChatRemoteDataSourceImpl();
              final repo = ChatRepositoryImpl(remote);
              return ChatHomePage(getDoctors: GetDoctors(repo));
            },
          ),
          // ACCOUNT
          GoRoute(
            path: AppRoutes.account,
            builder: (context, state) => const AccountPage(),
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final bool loggedIn = user != null;
      final bool loggingIn =
          state.matchedLocation == AppRoutes.login ||
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
