import '../repository/order_repository.dart';

class UpdateOrderStatus {
  final OrderRepository repository;

  UpdateOrderStatus(this.repository);

  Future<void> call(String id, String status) => repository.updateOrderStatus(id, status);
}

