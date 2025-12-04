import '../repository/order_repository.dart';

class DeleteOrder {
  final OrderRepository repository;

  DeleteOrder(this.repository);

  Future<void> call(String id) => repository.deleteOrder(id);
}

