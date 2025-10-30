import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/config/firebase_env.dart';
import 'core/routing/app_router.dart';

import 'feature/auth/presentation/providers/auth_provider.dart';
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource_impl.dart';
import 'package:hld_project/feature/Account/data/repositories/account_repository_impl.dart';
import 'package:hld_project/feature/Account/domain/account_repository/account_repository.dart';
import 'package:hld_project/feature/Account/domain/usecases/get_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/delete_account.dart';
import 'package:hld_project/feature/Account/presentation/provider/account_provider.dart';

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

  runApp(
    MultiProvider(
      providers: [
        // 1. PROVIDER CHO AUTH (Cái mày đang có)
        ChangeNotifierProvider.value(value: authProvider),
        Provider<IAccountRemoteDatasource>(
          create: (_) => AccountRemoteDatasourceImpl(),
        ),
        Provider<AccountRepository>(
          create: (context) => AccountRepositoryImpl(
            remoteDataSource: context.read<IAccountRemoteDatasource>(),
          ),
        ),

        // --- Tầng Domain (UseCases) ---
        Provider<GetAccount>(
          create: (context) => GetAccount(
            context.read<AccountRepository>(),
          ),
        ),
        Provider<DeleteAccount>(
          create: (context) => DeleteAccount( // (Sửa tên class cho đúng)
            context.read<AccountRepository>(),
          ),
        ),

        // --- Tầng Presentation (Provider chính) ---
        ChangeNotifierProvider<AccountProvider>(
          create: (context) => AccountProvider(
            getAccount: context.read<GetAccount>(),
            deleteAccountUseCase: context.read<DeleteAccount>(),
          )..fetchAccounts(), // Tự động gọi fetchAccounts khi app chạy
        ),
      ],
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