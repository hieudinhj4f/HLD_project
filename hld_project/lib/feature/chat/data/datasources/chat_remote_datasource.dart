import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<DoctorModel>> getDoctors();
  Future<void> bookAppointment(Map<String, dynamic> data);
  Future<void> sendMessage(String doctorId, MessageModel message);
  Stream<List<MessageModel>> getMessages(String doctorId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<DoctorModel>> getDoctors() async {
    final snapshot = await _firestore.collection('doctors').get();
    return snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> bookAppointment(Map<String, dynamic> data) async {
    await _firestore.collection('appointments').add(data);
  }

  @override
  Future<void> sendMessage(String doctorId, MessageModel message) async {
    await _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('messages')
        .add(message.toJson());
  }

  @override
  Stream<List<MessageModel>> getMessages(String doctorId) {
    return _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }
}