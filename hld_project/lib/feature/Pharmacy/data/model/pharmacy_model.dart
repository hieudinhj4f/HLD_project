// feature/Pharmacy/data/model/pharmacy_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/pharmacy.dart';

class PharmacyModel extends Pharmacy {
  const PharmacyModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.address,
    super.phone,
    required super.state,
    required super.staffCount,
    required super.ownerId,
    required super.createdAt,
    super.isActive = true,
  });

  // === FROM FIRESTORE ===
  factory PharmacyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PharmacyModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      address: data['address'] as String?,
      phone: data['phone'] as String?,
      state: data['state'] as String? ?? 'Pending',
      staffCount: (data['staffCount'] as num?)?.toInt() ?? 0,
      ownerId: data['ownerId'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt'] as String))
          : DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  // === FROM ENTITY ===
  factory PharmacyModel.fromEntity(Pharmacy entity) {
    return PharmacyModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      address: entity.address,
      phone: entity.phone,
      state: entity.state,
      staffCount: entity.staffCount,
      ownerId: entity.ownerId,
      createdAt: entity.createdAt,
      isActive: entity.isActive,
    );
  }

  // === TO ENTITY ===
  @override
  Pharmacy toEntity() => this;

  // === TO JSON (LƯU VÀO FIRESTORE) ===
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'address': address,
      'phone': phone,
      'state': state,
      'staffCount': staffCount,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}