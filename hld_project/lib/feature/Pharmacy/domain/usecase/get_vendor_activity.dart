import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

class GetVendorActivity {
  final PharmacyRepository repository;

  GetVendorActivity(this.repository);

  // Lấy dữ liệu biểu đồ (ví dụ: 7 ngày qua)
  Future<List<double>> call(String pharmacyId) async {
    return await repository.getVendorActivity(pharmacyId);
  }
}