
class Student{
  final String id;
  final String name;
  final String studentCode;
  final DateTime  birthDate;
  final String className;
  final String gender;
  final double gpa;
  final String phone;
  final DateTime createAt;
  final DateTime updateAt;

  const Student({
    required this.id,
    required this.name,
    required this.studentCode,
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
    return 'Student(id: $id , name: $name , studentCode: $studentCode , birthDate: $birthDate , className: $className , gender: $gender , GPA: $gpa, phone: $phone , createAt: $createAt, updateAt: $updateAt)';
  }
}