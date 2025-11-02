import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';


class UserEntity {
  final String uid;
  final String? email;
  final String role;
  final String name;
  final String dob;
  final String gender;
  final String phone;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String? pharmacyId; // <-- 1. ĐÃ THÊM TRƯỜNG MỚI

  const UserEntity({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    required this.dob,
    required this.gender,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.pharmacyId, // <-- 2. THÊM VÀO CONSTRUCTOR (không required)
  });

  factory UserEntity.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserEntity(
      uid: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      name: data['name'] ?? '',
      dob: data['dob'] ?? '',
      // Sửa logic: Chỉ cần một giá trị mặc định
      gender: data['gender'] ?? 'Nam',
      phone: data['phone'] ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updateAt'] as Timestamp? ?? Timestamp.now(),
      // 3. ĐỌC TỪ FIRESTORE
      pharmacyId: data['pharmacyId'] as String?,
    );
  }
}