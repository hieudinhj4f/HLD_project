import '../../domain/entities/student.dart';
import '../../domain/student_repository/student_repository.dart';
import '../datasource/student_remote_datasource.dart';

class StudentRepositoryImpl implements StudentRepo {
  final IStudentRemoteDatasource remoteDataSource;

  StudentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Student>> GetStudents() async {
    final models = await remoteDataSource.getAllStudents();
    return models.map((e) => e).toList();
  }

  @override
  Future<Student> CreateStudent(Student student) async {
    await remoteDataSource.addStudent(student);
    return student;
  }

  @override
  Future<Student> UpdateStudent(Student student) async {
    await remoteDataSource.updateStudent(student);
    return student;
  }

  @override
  Future<Student> DeleteStudent(String id) async {
    await remoteDataSource.deleteStudent(id);
    // tuỳ ý có thể trả về student đã xóa, hoặc null
    return Student(
      id: id,
      name: '',
      studentCode: '',
      birthDate: DateTime.now(),
      className: '',
      gender: '',
      gpa: 0,
      phone: '',
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
    );
  }
}
