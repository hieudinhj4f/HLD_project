import '../student_repository/student_repository.dart';

class DeleteStudent{
  final StudentRepo repo;
  DeleteStudent(this.repo);

  Future<void>  call(String id) => repo.DeleteStudent(id);
}