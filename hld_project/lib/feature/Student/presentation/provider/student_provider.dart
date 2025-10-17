import 'package:flutter/material.dart';
import '../../domain/usecases/delete_student.dart';
import '../../domain/usecases/get_student.dart';
import '../../domain/usecases/create_student.dart';
import '../../domain/entities/student.dart';
import '../../domain/usecases/update_student.dart';

class StudentProvider extends ChangeNotifier {
  final GetStudent getStudentsUseCase;
  final CreateStudent createStudentUseCase;
  final UpdateStudent updateStudentUseCase;
  final DeleteStudent deleteStudentUseCase;

  List<Student> _students = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Student> get students => _students;
  bool get isLoading => _isLoading;

  StudentProvider({
    required this.getStudentsUseCase,
    required this.createStudentUseCase,
    required this.updateStudentUseCase,
    required this.deleteStudentUseCase,
  });

  Future<void> fetchStudents() async {
    _isLoading = true;
    notifyListeners();

    _students = await getStudentsUseCase.call();

    _isLoading = false;
    notifyListeners();
  }

  List<Student> get filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    return _students
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> deleteStudent(String id) async {
    await deleteStudentUseCase.call(id);
    await fetchStudents(); // Cập nhật lại list
  }
}
