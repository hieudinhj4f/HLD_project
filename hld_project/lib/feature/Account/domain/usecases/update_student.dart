
import '../student_repository/student_repository.dart';
import '../entities/student.dart';

class UpdateStudent{
  final StudentRepo repo;
  UpdateStudent(this.repo);

  Future<Student> call(Student student) => repo.UpdateStudent(student);
}