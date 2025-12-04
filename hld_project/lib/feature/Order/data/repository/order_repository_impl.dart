import '../../domain/repository/order_repository.dart';
import '../../domain/entity/order.dart';
import '../datasource/order_remote_datasource.dart';
import '../model/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Order>> getAllOrders() async {
    final models = await _remoteDataSource.getAllOrders();
    return models.map<Order>((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Order>> getOrdersByUser(String userId) async {
    final models = await _remoteDataSource.getOrdersByUser(userId);
    return models.map<Order>((model) => model.toEntity()).toList();
  }

  @override
  Future<Order?> getOrderById(String id) async {
    final model = await _remoteDataSource.getOrderById(id);
    return model?.toEntity();
  }

  @override
  Future<void> createOrder(Order order) async {
    final model = OrderModel.fromEntity(order);
    await _remoteDataSource.createOrder(model);
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    await _remoteDataSource.updateOrderStatus(id, status);
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _remoteDataSource.deleteOrder(id);
  }
}

