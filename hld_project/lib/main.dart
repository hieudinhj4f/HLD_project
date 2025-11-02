import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/config/firebase_env.dart';
import 'core/routing/app_router.dart';
import 'feature/Pharmacy/domain/usecase/get_global_dashboard_stats.dart';
import 'feature/auth/presentation/providers/auth_provider.dart';

// --- 1. IMPORT CÁC FILE CẦN THIẾT ---
import 'feature/Pharmacy/presentation/providers/dashboard_provider.dart';

// Pharmacy (Đã có)
import 'feature/Pharmacy/domain/usecase/get_pharmacy_by_id.dart';
import 'feature/Pharmacy/domain/usecase/get_dashboard_stats.dart';
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
import 'feature/chat/domain/usecases/get_doctors.dart';
import 'feature/chat/data/repositories/chat_repository_impl.dart';
import 'feature/chat/data/datasources/chat_remote_datasource.dart';

// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/config/firebase_env.dart';
import 'core/routing/app_router.dart';
import 'feature/auth/presentation/providers/auth_provider.dart';

// === CHAT (USER) ===
import 'feature/chat/domain/usecases/get_doctors.dart';
import 'feature/chat/data/repositories/chat_repository_impl.dart';
import 'feature/chat/data/datasources/chat_remote_datasource.dart';

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
  final ChatRemoteDataSource chatDataSource = ChatRemoteDataSourceImpl();

  // === REPOSITORIES ===
  final pharmacyRepo = PharmacyRepositoryImpl(pharmacyDataSource);
  final productRepo = ProductRepositoryImpl(productDataSource);
  final doctorRepo = DoctorRepositoryImpl(doctorDataSource);
  final chatRepo = ChatRepositoryImpl(chatDataSource);

  // === USECASES ===
  // Pharmacy
  final getDashboardStats = GetDashboardStats(pharmacyRepo);
  final getGlobalDashboardStats = GetGlobalDashboardStats(pharmacyRepo); // THÊM
  final getVendorActivity = GetVendorActivity(pharmacyRepo);
  final getPharmacyById = GetPharmacyById(pharmacyRepo);
  final getAllPharmacies = GetAllPharmacy(pharmacyRepo); // ĐÃ SỬA
  final createPharmacy = CreatePharmacy(pharmacyRepo);     // ĐÃ SỬA
  final updatePharmacy = UpdatePharmacy(pharmacyRepo);     // ĐÃ SỬA
  final deletePharmacy = DeletePharmacy(pharmacyRepo);     // ĐÃ SỬA

  // Product
  final getAllProduct = GetAllProduct(productRepo);        // ĐÃ SỬA
  final createProduct = CreateProduct(productRepo);        // ĐÃ SỬA
  final updateProduct = UpdateProduct(productRepo);        // ĐÃ SỬA
  final deleteProduct = DeleteProduct(productRepo);        // ĐÃ SỬA

  // Doctor (Admin)
  final getAllDoctors = GetAllDoctor(doctorRepo);
  final createDoctor = CreateDoctor(doctorRepo);
  final updateDoctor = UpdateDoctor(doctorRepo);
  final deleteDoctor = DeleteDoctor(doctorRepo);

  // Chat (User)
  final getDoctors = GetDoctors(chatRepo);

  // === AUTH ===
  final authProvider = AuthProvider();

  // === DASHBOARD PROVIDER ===
  final dashboardProvider = DashboardProvider(
    authProvider: null,
    getDashboardStats: getDashboardStats,
    getVendorActivity: getVendorActivity,
    getPharmacyInfo: getPharmacyById,
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

  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (_) => dashboardProvider,
          update: (_, auth, previous) => previous!..updateAuth(auth),
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