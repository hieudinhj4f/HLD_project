class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isFromDoctor;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isFromDoctor,
  });
}