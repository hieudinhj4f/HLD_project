import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/get_total_products.dart';
import 'package:hld_project/feature/Product/domain/usecase/get_total_sold.dart';
import 'package:provider/provider.dart';
import 'core/config/firebase_env.dart';
import 'core/routing/app_router.dart';
import 'feature/Account/data/datasource/account_remote_datasource.dart';
import 'feature/Account/data/repositories/account_repository_impl.dart';
import 'feature/Account/domain/account_repository/account_repository.dart';
import 'feature/Account/domain/usecases/create_account.dart';
import 'feature/Account/domain/usecases/delete_account.dart';
import 'feature/Account/domain/usecases/get_account.dart';
import 'feature/Account/domain/usecases/update_account.dart';
import 'feature/Account/presentation/provider/account_provider.dart';
import 'feature/Pharmacy/domain/usecase/get_dashboard_stats.dart';
import 'feature/auth/presentation/providers/auth_provider.dart';

// --- 1. IMPORT CÁC FILE CẦN THIẾT ---
import 'feature/Pharmacy/presentation/providers/dashboard_provider.dart';

// Pharmacy (Đã có)
import 'feature/Pharmacy/domain/usecase/get_pharmacy_by_id.dart';
import 'feature/Pharmacy/domain/usecase/get_vendor_activity.dart';
import 'feature/Pharmacy/domain/usecase/getAllPharmacy.dart';
import 'feature/Pharmacy/domain/usecase/createPharmacy.dart';
import 'feature/Pharmacy/domain/usecase/updatePharmacy.dart';
import 'feature/Pharmacy/domain/usecase/deletePharmacy.dart';
import 'feature/Pharmacy/data/repository/pharmacy_repository_impl.dart';
import 'feature/Pharmacy/data/datasource/pharmacy_remote_datasource.dart';

// --- (THÊM MỚI) Product Imports ---
import 'feature/Product/domain/usecase/createProduct.dart';
import 'feature/Product/domain/usecase/deleteProduct.dart';
import 'feature/Product/domain/usecase/getProduct.dart'; // (Giả sử là GetAllProduct)
import 'feature/Product/domain/usecase/updateProduct.dart';
import 'feature/Product/data/repositories/product_repository_impl.dart';
import 'feature/Product/data/datasource/product_repository_datasource.dart';

// --- (THÊM MỚI) Doctor (Admin) Imports ---
import 'feature/chat/domain/usecases/create_doctor.dart';
import 'feature/chat/domain/usecases/delete_doctor.dart';
import 'feature/chat/domain/usecases/get_all_doctor.dart';
import 'feature/chat/domain/usecases/update_doctor.dart';
import 'feature/chat/data/repositories/doctor_repository_impl.dart';
import 'feature/chat/data/datasources/doctor_remote_datasource.dart';

// --- (THÊM MỚI) Chat (User) Imports ---
// Note: Chat repository is created inline in app_router

// --- (THÊM MỚI) Order Imports ---
import 'feature/Order/domain/usecases/get_all_orders.dart';
import 'feature/Order/domain/usecases/update_order_status.dart';
import 'feature/Order/domain/usecases/delete_order.dart';
import 'feature/Order/data/repository/order_repository_impl.dart';
import 'feature/Order/data/datasource/order_remote_datasource.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  // === DATA SOURCES ===
  final PharmacyRemoteDataSource pharmacyDataSource = PharmacyRemoteDataSourceImpl();
  final ProductRemoteDataSource productDataSource = ProductRemoteDataSourceImpl();
  final DoctorRemoteDatasource doctorDataSource = DoctorRemoteDataSourceImpl();
  // Note: ChatDataSource is created inline in app_router
  final AccountRemoteDatasource accountDataSource = AccountRemoteDatasourceIpml();
  final OrderRemoteDataSource orderDataSource = OrderRemoteDataSourceImpl();

  // === REPOSITORIES ===
  final pharmacyRepo = PharmacyRepositoryImpl(pharmacyDataSource);
  final productRepo = ProductRepositoryImpl(productDataSource);
  final doctorRepo = DoctorRepositoryImpl(doctorDataSource);
  // Note: ChatRepository is created inline in app_router
  final accountRepo = AccountRepositoryImpl(remoteDataSource: accountDataSource);
  final orderRepo = OrderRepositoryImpl(orderDataSource);

  // === USECASES ===
  // Pharmacy
  final getDashboardStats = GetDashboardStats(pharmacyRepo);
  // Note: GetGlobalDashboardStats kept for potential future use
  final getVendorActivity = GetVendorActivity(pharmacyRepo);
  final getPharmacyById = GetPharmacyById(pharmacyRepo);
  final getAllPharmacies = GetAllPharmacy(pharmacyRepo);
  final createPharmacy = CreatePharmacy(pharmacyRepo);
  final updatePharmacy = UpdatePharmacy(pharmacyRepo);
  final deletePharmacy = DeletePharmacy(pharmacyRepo);

  // Product
  final getAllProduct = GetAllProduct(productRepo);
  final createProduct = CreateProduct(productRepo);
  final updateProduct = UpdateProduct(productRepo);
  final deleteProduct = DeleteProduct(productRepo);
  final getAllProductUsecase = GetTotalProductsUseCase(pharmacyRepo);
  final GetTotalSold = getTotalSold(productRepo);

  // Doctor (Admin)
  final getAllDoctors = GetAllDoctor(doctorRepo);
  final createDoctor = CreateDoctor(doctorRepo);
  final updateDoctor = UpdateDoctor(doctorRepo);
  final deleteDoctor = DeleteDoctor(doctorRepo);

  // Account
  final getAccountUseCase = GetAccount(accountRepo);
  final createAccountUseCase = CreateAccount(accountRepo);
  final updateAccountUseCase = UpdateAccount(accountRepo);
  final deleteAccountUseCase = DeleteAccount(accountRepo);

  // Order
  final getAllOrders = GetAllOrders(orderRepo);
  final updateOrderStatus = UpdateOrderStatus(orderRepo);
  final deleteOrder = DeleteOrder(orderRepo);
  // === AUTH ===
  final authProvider = AuthProvider();

  // === DASHBOARD PROVIDER ===
  final dashboardProvider = DashboardProvider(
    getDashboardStats: getDashboardStats,
    getVendorActivity: getVendorActivity,
    getPharmacyInfo: getPharmacyById,
    getAllPharmacies: getAllPharmacies,
    getTotalProducts: getAllProductUsecase,
    getTotalSold: GetTotalSold,
  );

  // === APP ROUTER ===
  final appRouter = AppRouter(
    authProvider: authProvider,
    // Pharmacy
    getAllPharmacy: getAllPharmacies,
    createPharmacy: createPharmacy,
    updatePharmacy: updatePharmacy,
    deletePharmacy: deletePharmacy,
    // Product
    getAllProduct: getAllProduct,
    createProduct: createProduct,
    updateProduct: updateProduct,
    deleteProduct: deleteProduct,
    // Doctor
    getAllDoctors: getAllDoctors,
    createDoctor: createDoctor,
    updateDoctor: updateDoctor,
    deleteDoctor: deleteDoctor,
    // Chat
    // Account
    getAccountUseCase: getAccountUseCase,
    createAccountUseCase: createAccountUseCase,
    updateAccountUseCase: updateAccountUseCase,
    deleteAccountUseCase: deleteAccountUseCase,
    // Order
    getAllOrders: getAllOrders,
    updateOrderStatus: updateOrderStatus,
    deleteOrder: deleteOrder,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (_) => dashboardProvider,
          update: (_, auth, previous) => previous!..updateAuth(auth),
        ),
        Provider<AccountRemoteDatasource>(
          // (Mày tự sửa tên Ipml nếu cần)
          create: (_) => AccountRemoteDatasourceIpml(),
        ),
        Provider<AccountRepository>(
          create: (context) => AccountRepositoryImpl(
            remoteDataSource: context.read<AccountRemoteDatasource>(),
          ),
        ),
        // --- Tầng Domain (UseCases) ---
        Provider<GetAccount>(
          create: (context) => GetAccount(
            context.read<AccountRepository>(),
          ),
        ),
        Provider<CreateAccount>(
          create: (context) => CreateAccount(
            context.read<AccountRepository>(),
          ),
        ),
        Provider<UpdateAccount>(
          create: (context) => UpdateAccount(
            context.read<AccountRepository>(),
          ),
        ),
        Provider<DeleteAccount>(
          create: (context) => DeleteAccount(
            context.read<AccountRepository>(),
          ),
        ),
        // --- Tầng Presentation (Cái AccountProvider của mày) ---
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
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'HLD Project',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      routerConfig: appRouter.router,
    );
  }
}