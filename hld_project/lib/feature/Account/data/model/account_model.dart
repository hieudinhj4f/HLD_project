// file: lib/feature/Account/data/model/account_model.dart
import '../../domain/entities/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.gender,
    required super.dob,
    required super.age,
    required super.address,
    required super.role,
    required super.createAt,
    required super.updateAt,
  });

  // ==========================================================
  // HÀM 1: Đọc từ Firestore (Đã sửa cho an toàn)
  // ==========================================================
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime(1970);
      if (dateValue is Timestamp) return dateValue.toDate();
      if (dateValue is String) return DateTime.parse(dateValue);
      return DateTime(1970);
    }

    return AccountModel(
      id: json['id'] as String,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      age: json['age'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? 'user',
      createAt: _parseDate(json['createdAt']), // Khớp tên field
      updateAt: _parseDate(json['updatedAt']), // Khớp tên field
    );
  }

  // ==========================================================
  // HÀM 2: Ghi vào Firestore (Mày thiếu cái này)
  // ==========================================================
  Map<String, dynamic> toJson() => {
    // Không cần 'id' vì nó là tên document
    'name': name,
    'email': email,
    'phone': phone,
    'gender': gender,
    'dob': dob,
    'age': age,
    'address': address,
    'role': role,
    'createdAt': Timestamp.fromDate(createAt), // Chuyển về Timestamp
    'updatedAt': Timestamp.fromDate(updateAt), // Chuyển về Timestamp
  };

  // ==========================================================
  // HÀM 3: Chuyển Entity -> Model (Mày thiếu cái này)
  // (Dùng khi update/create)
  // ==========================================================
  factory AccountModel.fromEntity(Account account) {
    return AccountModel(
      id: account.id,
      name: account.name,
      email: account.email,
      phone: account.phone,
      gender: account.gender,
      dob: account.dob,
      age: account.age,
      address: account.address,
      role: account.role,
      createAt: account.createAt,
      updateAt: account.updateAt,
    );
  }
}