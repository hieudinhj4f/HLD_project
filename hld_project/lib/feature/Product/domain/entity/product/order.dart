class orderI4 {
  final String id;
  final String orderNumber;
  final double totalAmount;
  final String senderName;
  final String receiverName;
  final String status;
  final DateTime createdAt;

  orderI4({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.senderName,
    required this.receiverName,
    required this.status,
    required this.createdAt,
  });
}