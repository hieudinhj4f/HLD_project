import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/order.dart' as order_entity;

class OrderModel {
  final String id;
  final String orderNumber;
  final double totalAmount;
  final String senderName;
  final String receiverName;
  final String status;
  final DateTime createdAt;
  final String? userId;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.senderName,
    required this.receiverName,
    required this.status,
    required this.createdAt,
    this.userId,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      orderNumber: data['orderNumber'] ?? '',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      senderName: data['senderName'] ?? '',
      receiverName: data['receiverName'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] as String?,
    );
  }

  factory OrderModel.fromEntity(order_entity.Order order) {
    return OrderModel(
      id: order.id,
      orderNumber: order.orderNumber,
      totalAmount: order.totalAmount,
      senderName: order.senderName,
      receiverName: order.receiverName,
      status: order.status,
      createdAt: order.createdAt,
      userId: order.userId,
    );
  }

  order_entity.Order toEntity() {
    return order_entity.Order(
      id: id,
      orderNumber: orderNumber,
      totalAmount: totalAmount,
      senderName: senderName,
      receiverName: receiverName,
      status: status,
      createdAt: createdAt,
      userId: userId,
    );
  }

  Map<String, dynamic> toJson() => {
    'orderNumber': orderNumber,
    'totalAmount': totalAmount,
    'senderName': senderName,
    'receiverName': receiverName,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
    if (userId != null) 'userId': userId,
  };
}

