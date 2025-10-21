import '../../domain/entities/account.dart';
class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.name,
    required super.accountCode,
    required super.birthDate,
    required super.className,
    required super.gender,
    required super.gpa,
    required super.phone,
    required super.createAt,
    required super.updateAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      accountCode: json['accountCode'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      className: json['className'] as String,
      gender: json['gender'] as String,
      gpa: (json['gpa'] as num).toDouble(),
      phone: json['phone'] as String,
      createAt: DateTime.parse(json['createAt'] as String),
      updateAt: DateTime.parse(json['updateAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'accountCode': accountCode,
    'birthDate': birthDate.toIso8601String(),
    'className': className,
    'gender': gender,
    'gpa': gpa,
    'phone': phone,
    'createAt': createAt.toIso8601String(),
    'updateAt': updateAt.toIso8601String(),
  };
  factory AccountModel.fromEntity(Account account){
    return AccountModel(
      id: account.id,
      name: account.name,
      accountCode: account.accountCode,
      birthDate: account.birthDate,
      className: account.className,
      gender: account.gender,
      gpa:  account.gpa,
      phone: account.phone,
      createAt: account.createAt,
      updateAt: account.updateAt,
      );
  }
}
