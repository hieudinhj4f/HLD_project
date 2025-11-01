import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hld_project/feature/Product/domain/entity/product/order.dart';

class OrderModel extends orderI4 {
  OrderModel({
    required super.id,
    required super.orderNumber,
    required super.totalAmount,
    required super.senderName,
    required super.receiverName,
    required super.status,
    required super.createdAt,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'orderNumber': orderNumber,
    'totalAmount': totalAmount,
    'senderName': senderName,
    'receiverName': receiverName,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
