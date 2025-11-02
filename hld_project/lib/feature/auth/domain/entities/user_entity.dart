import 'package:cloud_firestore/cloud_firestore.dart';


class UserEntity {
  final String uid;
  final String? email;
  final String role;
  final String name;
  final String dob;
  final String gender;
  final String phone;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const UserEntity({
    required this.uid,
    this.email,
    this.role = 'user',
    this.name = '',
    this.dob = '',
    this.gender = 'Nam',
    this.phone = '',
    this.createdAt,
    this.updatedAt,
  });

  factory UserEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserEntity(
      uid: doc.id,
      email: data['email'] as String?,
      role: data['role'] as String? ?? 'user',
      name: data['name'] as String? ?? '',
      dob: data['dob'] as String? ?? '',
      gender: data['gender'] as String? ?? 'Nam',
      phone: data['phone'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'dob': dob,
      'gender': gender,
      'phone': phone,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}