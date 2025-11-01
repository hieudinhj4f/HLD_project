import '../entities/doctor.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<List<Doctor>> getDoctors();
  Future<void> bookAppointment(Map<String, dynamic> appointmentData);
  Future<void> sendMessage(String doctorId, Message message);
  Stream<List<Message>> getMessages(String doctorId);
}