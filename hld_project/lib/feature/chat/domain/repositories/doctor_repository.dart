import 'package:hld_project/feature/chat/domain/entities/doctor.dart';

abstract class DoctorRepository {
  Future<List<Doctor>> GetAllDoctor();
  Future<void> CreateDoctor(Doctor doctor);
  Future<Doctor?> GetDoctorbyID(String id);
  Future<void> DeleteDoctor(String id);
  Future<void> UpdateDoctor(Doctor doctor);
}