import '../repositories/chat_repository.dart';

class BookAppointment {
  final ChatRepository repository;
  BookAppointment(this.repository);

  Future<void> call(Map<String, dynamic> data) => repository.bookAppointment(data);
}