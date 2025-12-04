import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getAllOrders();
  Future<List<OrderModel>> getOrdersByUser(String userId);
  Future<OrderModel?> getOrderById(String id);
  Future<String> createOrder(OrderModel order);
  Future<void> updateOrderStatus(String id, String status);
  Future<void> deleteOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      // If composite index error, try without orderBy
      if (e.toString().contains('index')) {
        final snapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .get();
        final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
        // Sort manually
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return orders;
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    final doc = await _firestore.collection('orders').doc(id).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  @override
  Future<String> createOrder(OrderModel order) async {
    final docRef = await _firestore.collection('orders').add(order.toJson());
    return docRef.id;
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    await _firestore.collection('orders').doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _firestore.collection('orders').doc(id).delete();
  }
}

