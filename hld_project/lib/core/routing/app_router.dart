import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hld_project/feature/Home/presentation/pages/home_page.dart';
import '../../feature/Home/presentation/pages/splash_screen.dart';
import '../../feature/Student/presentation/pages/student_list_page.dart';
import '../../feature/auth/presentation/pages/signup_page.dart';
import '../presentation/widget/customeButtomNav.dart';
import '../routing/app_routers.dart';
import '../../feature/auth/presentation/pages/login_page.dart';
import 'go_router_refresh_change.dart';

class AppGoRouter {

  static int _getIndexForLocation(String path){
    if ( path.startsWith(AppRoutes.home)) return 0;
    else if ( path.startsWith(AppRoutes.profile)) return 1;
    else if ( path.startsWith(AppRoutes.chat)) return 2;
    else if ( path.startsWith(AppRoutes.account)) return 3;

  }
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
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
        builder: (context,state) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context,state) => const HomeScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('CARLY Showroom - Student Manager'),
            ),
            body: child,
            bottomNavigationBar: CustomBottomNav(onItemTapped: (int p1) {  },, selectedIndex: null,),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const StudentListPage(),
          ),
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
