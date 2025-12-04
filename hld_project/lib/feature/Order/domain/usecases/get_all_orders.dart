import '../repository/order_repository.dart';
import '../entity/order.dart';

class GetAllOrders {
  final OrderRepository repository;

  GetAllOrders(this.repository);

  Future<List<Order>> call() => repository.getAllOrders();
}

