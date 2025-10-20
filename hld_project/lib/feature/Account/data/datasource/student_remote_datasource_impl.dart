import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hld_project/feature/Student/data/datasource/student_remote_datasource.dart';
import 'package:hld_project/feature/Student/data/model/student_model.dart';
import 'package:hld_project/feature/Student/domain/entities/student.dart';


class StudentRemoteDatasourceImpl implements IStudentRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'student';

  @override
  Future<List<StudentModel>> getAllStudents() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return StudentModel.fromJson({
        'id': doc.id,
        ...data,
      });
    }).toList();
  }

  @override
  Future<StudentModel> getStudentById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('Account not found');
    final data = doc.data()!;
    return StudentModel.fromJson({'id': doc.id, ...data});
  }

  @override
  Future<void> addStudent(Student student) async {
    final model = StudentModel.fromEntity(student);
    await _firestore.collection(_collection).add(model.toJson());
  }

  @override
  Future<void> updateStudent(Student student) async {
    final model = StudentModel.fromEntity(student);
    await _firestore.collection(_collection).doc(student.id).update(model.toJson());
  }

  @override
  Future<void> deleteStudent(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
