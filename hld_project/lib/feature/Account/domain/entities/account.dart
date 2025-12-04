class Account{
  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String dob;
  final String age;
  final String address;
  final String role;
  final DateTime createAt;
  final DateTime updateAt;
  final String avatarUrl;

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
    required this.avatarUrl,
  });
}