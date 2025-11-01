import '../../domain/entities/doctor.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/doctor_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Doctor>> getDoctors() async {
    final models = await _remoteDataSource.getDoctors();
    return models;
  }

  @override
  Future<void> bookAppointment(Map<String, dynamic> data) async {
    await _remoteDataSource.bookAppointment(data);
  }

  @override
  Future<void> sendMessage(String doctorId, Message message) async {
    final model = MessageModel(
      id: '',
      senderId: message.senderId,
      content: message.content,
      timestamp: message.timestamp,
      isFromDoctor: message.isFromDoctor,
    );
    await _remoteDataSource.sendMessage(doctorId, model);
  }

  @override
  Stream<List<Message>> getMessages(String doctorId) {
    return _remoteDataSource.getMessages(doctorId).map((models) => models);
  }
}