import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;
  SendMessage(this.repository);

  Future<void> call(String doctorId, Message message) => repository.sendMessage(doctorId, message);
}