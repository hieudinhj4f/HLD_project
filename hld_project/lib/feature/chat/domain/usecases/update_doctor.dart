import 'package:hld_project/feature/chat/domain/entities/doctor.dart';
import 'package:hld_project/feature/chat/domain/repositories/doctor_repository.dart';

class UpdateDoctor {
  final DoctorRepository dp;
  UpdateDoctor(this.dp);

  Future<void> call(Doctor doctor) async => await dp.UpdateDoctor(doctor) ;
}