import '../entities/student.dart';

abstract class StudentRepo {
  Future<List<Student>> GetStudents();
  Future<Student> CreateStudent(Student student);
  Future<Student> UpdateStudent(Student student);
  Future<Student> DeleteStudent(String id);
}