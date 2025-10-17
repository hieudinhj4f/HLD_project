import '../entities/student.dart';
import '../student_repository/student_repository.dart';

class CreateStudent{
  final StudentRepo repo;
  CreateStudent(this.repo);

  Future<Student> call(Student student)  =>   repo.CreateStudent(student);
}