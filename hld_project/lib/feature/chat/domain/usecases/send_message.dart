import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;
  SendMessage(this.repository);

  Future<void> call(String doctorId, Message message) async =>  await repository.sendMessage(doctorId, message);
}