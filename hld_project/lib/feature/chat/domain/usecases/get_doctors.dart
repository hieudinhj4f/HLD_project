import '../entities/doctor.dart';
import '../repositories/chat_repository.dart';

class GetDoctors {
  final ChatRepository repository;
  GetDoctors(this.repository);

  Future<List<Doctor>> call() => repository.getDoctors();
}