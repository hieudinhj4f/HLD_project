import '../../../../core/data/firebase_remote_datasource.dart';
import '../model/pharmacy_model.dart';

abstract class PharmacyRemoteDatasource {
  Future<List<PharmacyModel>> getAll();
  Future<PharmacyModel?> getPharmacy(String id);
  Future<void> add(PharmacyModel pharmacy);
  Future<void> update(PharmacyModel pharmacy);
  Future<void> delete(String id);
}

class PharmacyRemoteDataSourceImpl implements PharmacyRemoteDatasource {
  // 1. Khai báo lớp generic FirebaseRemoteDS
  final FirebaseRemoteDS<PharmacyModel> _remoteSource;

  // 2. Khởi tạo nó trong constructor
  PharmacyRemoteDataSourceImpl()
      : _remoteSource = FirebaseRemoteDS<PharmacyModel>(
    // Tên collection trên Firestore
    collectionName: 'pharmacy',

    // Hàm chuyển đổi từ Firestore (snapshot) -> Model
    fromFirestore: (doc) => PharmacyModel.fromFirestore(doc),

    // Hàm chuyển đổi từ Model -> JSON (Map)
    toFirestore: (model) => model.toJson(),
  );

  // 3. Triển khai các phương thức bằng cách gọi _remoteSource
  @override
  Future<List<PharmacyModel>> getAll() async {
    final pharmacies = await _remoteSource.getAll();
    return pharmacies;
  }

  @override
  Future<PharmacyModel?> getPharmacy(String id) async {
    final pharmacy = await _remoteSource.getById(id);
    return pharmacy;
  }

  @override
  Future<void> add(PharmacyModel pharmacy) async {
    await _remoteSource.add(pharmacy);
  }

  @override
  Future<void> update(PharmacyModel pharmacy) async {
    // Giả sử pharmacy.id là String. Nếu không, dùng pharmacy.id.toString()
    await _remoteSource.update(pharmacy.id, pharmacy);
  }

  @override
  Future<void> delete(String id) async {
    await _remoteSource.delete(id);
  }
}