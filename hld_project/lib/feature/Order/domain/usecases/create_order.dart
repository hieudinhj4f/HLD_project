import '../repository/order_repository.dart';
import '../entity/order.dart';

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  Future<void> call(Order order) => repository.createOrder(order);
}

