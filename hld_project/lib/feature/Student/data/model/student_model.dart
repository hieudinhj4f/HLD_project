import '../../domain/entities/student.dart';
class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.studentCode,
    required super.birthDate,
    required super.className,
    required super.gender,
    required super.gpa,
    required super.phone,
    required super.createAt,
    required super.updateAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      studentCode: json['studentCode'] as String,
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
    'studentCode': studentCode,
    'birthDate': birthDate.toIso8601String(),
    'className': className,
    'gender': gender,
    'gpa': gpa,
    'phone': phone,
    'createAt': createAt.toIso8601String(),
    'updateAt': updateAt.toIso8601String(),
  };
  factory StudentModel.fromEntity(Student student){
    return StudentModel(
      id: student.id,
      name: student.name,
      studentCode: student.studentCode,
      birthDate: student.birthDate,
      className: student.className,
      gender: student.gender,
      gpa:  student.gpa,
      phone: student.phone,
      createAt: student.createAt,
      updateAt: student.updateAt,
      );
  }
}
