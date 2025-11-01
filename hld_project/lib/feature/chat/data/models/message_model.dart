import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.senderId,
    required super.content,
    required super.timestamp,
    required super.isFromDoctor,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isFromDoctor: data['isFromDoctor'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'senderId': senderId,
        'content': content,
        'timestamp': Timestamp.fromDate(timestamp),
        'isFromDoctor': isFromDoctor,
      };
}