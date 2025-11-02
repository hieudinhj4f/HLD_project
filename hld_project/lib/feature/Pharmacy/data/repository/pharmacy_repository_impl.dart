import 'package:hld_project/feature/Pharmacy/data/datasource/pharmacy_remote_datasource.dart';
import 'package:hld_project/feature/Pharmacy/data/model/pharmacy_model.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/pharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/repository/pharmacy_repository.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  // 1. Phụ thuộc vào lớp Abstract Datasource
  final PharmacyRemoteDatasource remoteDatasource;

  // 2. Tiêm (Inject) Datasource vào constructor
  PharmacyRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> createPharmacy(Pharmacy pharmacy) async {
    // Chuyển Entity (sạch) -> Model (bẩn) để gửi đi
    final pharmacyModel = PharmacyModel.fromEntity(pharmacy);
    await remoteDatasource.add(pharmacyModel);
  }

  @override
  Future<void> deletePharmacy(String id) async {
    await remoteDatasource.delete(id);
  }

  @override
  Future<List<Pharmacy>> GetAllPharmacy() async {

    // 1. Gọi Datasource, nhận về List<Model>
    final pharmacyModels = await remoteDatasource.getAll();

    // 2. Chuyển List<Model> -> List<Entity> và trả về cho Domain
    final pharmacies = pharmacyModels
        .map((model) => model.toEntity())
        .toList();
    return pharmacies;
  }

  @override
  Future<Pharmacy?> getPharmacyById(String id) async {
    // 1. Gọi Datasource, nhận về Model?
    final pharmacyModel = await remoteDatasource.getPharmacy(id);

    // 2. Nếu model tồn tại, chuyển nó thành Entity và trả về
    if (pharmacyModel != null) {
      return pharmacyModel.toEntity();
    }
    return null;
  }

  @override
  Future<void> updatePharmacy(Pharmacy pharmacy) async {
    // Chuyển Entity (sạch) -> Model (bẩn) để gửi đi
    final pharmacyModel = PharmacyModel.fromEntity(pharmacy);
    await remoteDatasource.update(pharmacyModel);
  }

  // --- HÀM NÀY BỊ SAI TÊN TRONG FILE CỦA BẠN ---
  // Bạn nên xóa hàm này và dùng hàm 'getAllPharmacies' ở trên
  @override
  Future<List<Pharmacy>> getAllProducts() {
    return remoteDatasource.getAll();
  }
}