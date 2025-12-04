import '../repository/order_repository.dart';
import '../entity/order.dart';

class GetOrdersByUser {
  final OrderRepository repository;

  GetOrdersByUser(this.repository);

  Future<List<Order>> call(String userId) => repository.getOrdersByUser(userId);
}

