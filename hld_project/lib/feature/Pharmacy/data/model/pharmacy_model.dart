import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/pharmacy.dart';

// 1. LỚP MODEL KẾ THỪA TỪ ENTITY
// Lớp Model chứa các logic "bẩn" (dirty logic) liên quan đến việc
// chuyển đổi dữ liệu từ các nguồn bên ngoài (như Firestore).
class PharmacyModel extends Pharmacy {
  PharmacyModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.destination,
    required super.hotline,
    required super.taxId,
    required super.presentative,
  });

  // 2. FACTORY: CHUYỂN DỮ LIỆU TỪ FIRESTORE (DocumentSnapshot) -> MODEL
  // Đây là "cửa vào" từ Data Layer.
  factory PharmacyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PharmacyModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      destination: data['destination'] ?? '',
      hotline: data['hotline'] ?? '',
      taxId: data['taxId'] ?? '',
      presentative: data['presentative'] ?? '',
    );
  }

  // 3. FACTORY: CHUYỂN TỪ ENTITY (Domain) -> MODEL (Data)
  // Dùng khi Usecase ở Domain Layer muốn "gửi" một object sạch
  // xuống Data Layer để ghi vào DB.
  factory PharmacyModel.fromEntity(Pharmacy pharmacy) {
    return PharmacyModel(
      id: pharmacy.id,
      name: pharmacy.name,
      imageUrl: pharmacy.imageUrl,
      destination: pharmacy.destination,
      hotline: pharmacy.hotline,
      taxId: pharmacy.taxId,
      presentative: pharmacy.presentative,
    );
  }

  // 4. METHOD: CHUYỂN TỪ MODEL -> ENTITY
  // Dùng khi Repository ở Data Layer muốn "trả về" một object sạch
  // cho Domain Layer (Usecase) sử dụng.
  Pharmacy toEntity() {
    return Pharmacy(
      id: id,
      name: name,
      imageUrl: imageUrl,
      destination: destination,
      hotline: hotline,
      taxId: taxId,
      presentative: presentative,
    );
  }

  // 5. METHOD: CHUYỂN TỪ MODEL -> JSON (Map) ĐỂ GHI LÊN FIRESTORE
  // Đây là "cửa ra" đi đến Data Layer.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'destination': destination,
      'hotline': hotline,
      'taxId': taxId,
      'presentative': presentative,
      // Không cần 'id' vì nó là tên của Document
    };
  }
}