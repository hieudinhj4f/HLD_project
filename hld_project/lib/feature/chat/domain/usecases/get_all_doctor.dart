import 'package:hld_project/feature/chat/domain/repositories/doctor_repository.dart';

import '../entities/doctor.dart';
import '../repositories/chat_repository.dart';

class GetAllDoctor {
  final DoctorRepository repository;
  GetAllDoctor(this.repository);

  Future<List<Doctor>> call()  async => await repository.GetAllDoctor();
}