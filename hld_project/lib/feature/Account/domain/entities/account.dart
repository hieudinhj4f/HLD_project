
class Account{
  final String id;
  final String name;
  final String accountCode;
  final DateTime birthDate;
  final String className;
  final String gender;
  final double gpa;
  final String phone;
  final DateTime createAt;
  final DateTime updateAt;

  const Account({
    required this.id,
    required this.name,
    required this.accountCode,
    required this.birthDate,
    required this.className,
    required this.gender,
    required this.gpa,
    required this.phone,
    required this.createAt,
    required this.updateAt,
});
  @override
  String toString(){
    return 'Account(id: $id , name: $name , accountCode: $accountCode , birthDate: $birthDate , className: $className , gender: $gender , GPA: $gpa, phone: $phone , createAt: $createAt, updateAt: $updateAt)';
  }
}