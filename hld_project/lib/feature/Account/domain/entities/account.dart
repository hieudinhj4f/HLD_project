// file: lib/feature/Account/domain/entities/account.dart

class Account{
  final String id;
  final String name;
  final String email; // Mày có 'email'
  final String phone;
  final String gender;
  final String dob; // Mày dùng 'dob' (String)
  final String age; // Mày có 'age'
  final String address; // Mày có 'address'
  final String role; // Mày có 'role'
  final DateTime createAt; // (tên field là createdAt)
  final DateTime updateAt; // (tên field là updatedAt)

  const Account({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.age,
    required this.address,
    required this.role,
    required this.createAt,
    required this.updateAt,
  });
}