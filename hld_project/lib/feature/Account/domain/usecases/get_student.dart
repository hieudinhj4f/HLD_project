import '../student_repository/student_repository.dart';
import '../entities/student.dart';
class GetStudent{
  final StudentRepo repo;
  GetStudent(this.repo);

  Future<List<Student>> call() => repo.GetStudents();
}