import 'package:hld_project/feature/Student/data/model/student_model.dart';
import 'package:hld_project/feature/Student/domain/entities/student.dart';


/// Interface cơ bản định nghĩa hành vi của datasource
abstract class IStudentRemoteDatasource {
  Future<List<StudentModel>> getAllStudents();
  Future<StudentModel> getStudentById(String id);
  Future<void> addStudent(Student student);
  Future<void> updateStudent(Student student);
  Future<void> deleteStudent(String id);
}
