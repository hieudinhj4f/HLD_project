import '../entity/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getAllOrders();
  Future<List<Order>> getOrdersByUser(String userId);
  Future<Order?> getOrderById(String id);
  Future<void> createOrder(Order order);
  Future<void> updateOrderStatus(String id, String status);
  Future<void> deleteOrder(String id);
}

