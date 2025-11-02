import 'package:hld_project/feature/chat/domain/entities/doctor.dart';
import 'package:hld_project/feature/chat/domain/repositories/doctor_repository.dart';

class DeleteDoctor{
  final DoctorRepository dp;
  DeleteDoctor(this.dp);
  Future<void> call(String id) async => await dp.DeleteDoctor(id);
}