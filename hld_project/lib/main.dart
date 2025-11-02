import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/config/firebase_env.dart';
import 'core/routing/app_router.dart';
import 'feature/auth/presentation/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load file env de config cau hinh
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FirebaseEnv.apiKey,
      appId: FirebaseEnv.appId,
      messagingSenderId: FirebaseEnv.messagingSenderId,
      projectId: FirebaseEnv.projectId,
      authDomain: FirebaseEnv.authDomain,
      storageBucket: FirebaseEnv.storageBucket,
      measurementId: FirebaseEnv.measurementId,
    ),
  );


  final AuthProvider authProvider = AuthProvider();
  final AppRouter appRouter = AppRouter(authProvider);

  // --- 3. CHẠY ỨNG DỤNG VỚI PROVIDER ---
  runApp(
    // Dùng ChangeNotifierProvider.value để cung cấp
    // instance authProvider đã được tạo
    ChangeNotifierProvider.value(
      value: authProvider,
      child: MyApp(appRouter: appRouter),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({
    super.key,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'HLD Project',
      routerConfig: appRouter.router,
    );
  }
}