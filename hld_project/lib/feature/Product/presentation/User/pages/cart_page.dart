import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import 'package:hld_project/feature/Order/domain/entity/order.dart' as order_entity;
import 'package:hld_project/feature/Order/domain/usecases/create_order.dart';
import 'package:hld_project/feature/Order/data/repository/order_repository_impl.dart';
import 'package:hld_project/feature/Order/data/datasource/order_remote_datasource.dart';
import 'package:hld_project/feature/Pharmacy/data/repository/pharmacy_repository_impl.dart';
import 'package:hld_project/feature/Pharmacy/data/datasource/pharmacy_remote_datasource.dart';
import 'package:hld_project/feature/Pharmacy/domain/usecase/update_order_revenue.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double _total = 0.0;
  String _orderNumber = '';

  @override
  void initState() {
    super.initState();
    _generateOrderNumber();
  }

  void _generateOrderNumber() {
    _orderNumber = DateTime.now().millisecondsSinceEpoch.toString().substring(
      6,
    );
  }

  // Update quantity
  Future<void> _updateQuantity(
      String userId,
      String productId,
      int change,
      ) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId);

    final doc = await docRef.get();
    if (doc.exists) {
      final currentQty = (doc.data()?['quantity'] as num?)?.toInt() ?? 0;
      final newQty = currentQty + change;
      if (newQty <= 0) {
        await docRef.delete();
      } else {
        await docRef.update({'quantity': newQty});
      }
    }
  }

  // Clear the entire cart
  Future<void> _clearCart(String userId) async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // FIXED: SKIP NON-EXISTENT PRODUCTS -> NO ERROR
  Future<void> _deductStock(String userId) async {
    final batch = FirebaseFirestore.instance.batch();
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    for (var doc in cartSnapshot.docs) {
      final data = doc.data();
      final productId = data['productId'] as String?;
      final qtyBought = (data['quantity'] as num?)?.toInt() ?? 1;

      if (productId != null) {
        final productRef = FirebaseFirestore.instance
            .collection('product')
            .doc(productId);

        // CHECK IF THE PRODUCT EXISTS
        final productSnap = await productRef.get();
        if (productSnap.exists) {
          batch.update(productRef, {
            'quantity': FieldValue.increment(-qtyBought),
            'sold': FieldValue.increment(qtyBought),
          });
        }
        // If it doesn't exist -> SKIP, NO ERROR
      }
    }

    await batch.commit();
  }

  // Update revenue AFTER all processes are complete
  // This groups cart items by pharmacy and updates revenue for each pharmacy
  Future<void> _updateRevenueFromCartItems(List<Map<String, dynamic>> cartItemsData) async {
    if (cartItemsData.isEmpty) return;

    // Group cart items by pharmacyId
    final Map<String, List<Map<String, dynamic>>> pharmacyGroups = {};

    for (var itemData in cartItemsData) {
      final productId = itemData['productId'] as String?;
      final quantity = (itemData['quantity'] as num?)?.toInt() ?? 1;
      final price = (itemData['price'] as num?)?.toDouble() ?? 0.0;

      if (productId != null && quantity > 0) {
        // Get pharmacyId from product
        final productDoc = await FirebaseFirestore.instance
            .collection('product')
            .doc(productId)
            .get();

        if (productDoc.exists) {
          final productData = productDoc.data();
          final pharmacyId = productData?['pharmacyId'] as String?;

          if (pharmacyId != null && pharmacyId.isNotEmpty) {
            if (!pharmacyGroups.containsKey(pharmacyId)) {
              pharmacyGroups[pharmacyId] = [];
            }

            pharmacyGroups[pharmacyId]!.add({
              'quantity': quantity,
              'price': price,
              'subtotal': price * quantity,
            });
          }
        }
      }
    }

    // Update revenue for each pharmacy
    final pharmacyRepo = PharmacyRepositoryImpl(PharmacyRemoteDataSourceImpl());
    final updateRevenueUseCase = UpdateOrderRevenue(pharmacyRepo);

    for (var entry in pharmacyGroups.entries) {
      final pharmacyId = entry.key;
      final items = entry.value;

      // Calculate total revenue for this pharmacy
      double pharmacyTotal = 0.0;
      int pharmacyItemsSold = 0;

      for (var item in items) {
        pharmacyTotal += item['subtotal'] as double;
        pharmacyItemsSold += item['quantity'] as int;
      }

      // Update revenue AFTER all processes are done
      await updateRevenueUseCase.call(
        pharmacyId: pharmacyId,
        totalAmount: pharmacyTotal,
        itemsSold: pharmacyItemsSold,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Cart',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: Text('Please log in to see your cart')),
      );
    }

    final cartCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!.docs;
          _total = 0.0;
          for (var item in cartItems) {
            final data = item.data() as Map<String, dynamic>;
            final price = (data['price'] as num?)?.toDouble() ?? 0.0;
            final quantity = (data['quantity'] as num?)?.toInt() ?? 1;
            _total += price * quantity;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final doc = cartItems[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Product';
                    final price = (data['price'] as num?)?.toDouble() ?? 0.0;
                    final quantity = (data['quantity'] as num?)?.toInt() ?? 1;
                    final imageUrl = data['imageUrl'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${price.toStringAsFixed(0)}đ',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _updateQuantity(userId, doc.id, -1),
                                    ),
                                    Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _updateQuantity(userId, doc.id, 1),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      cartCollection.doc(doc.id).delete(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // TOTAL + CHECKOUT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(fontSize: 16)),
                        Text(
                          '${_total.toStringAsFixed(0)}đ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shipping fee'),
                        Text('0đ', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_total.toStringAsFixed(0)}đ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _clearCart(userId),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Clear all'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _total > 0
                                ? () async {
                              try {
                                // STEP 1: Save cart items data BEFORE clearing
                                final cartSnapshot = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .collection('cart')
                                    .get();
                                
                                final cartItemsData = cartSnapshot.docs
                                    .map((doc) => doc.data())
                                    .toList();

                                // STEP 2: DEDUCT STOCK
                                await _deductStock(userId);

                                // STEP 3: CREATE ORDER
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                final userName = authProvider.user?.name ?? 'User';
                                
                                final orderRepo = OrderRepositoryImpl(OrderRemoteDataSourceImpl());
                                final createOrderUseCase = CreateOrder(orderRepo);
                                
                                // Generate temporary ID (will be replaced by Firestore)
                                final tempId = DateTime.now().millisecondsSinceEpoch.toString();
                                final order = order_entity.Order(
                                  id: tempId,
                                  orderNumber: _orderNumber,
                                  totalAmount: _total,
                                  senderName: userName,
                                  receiverName: userName, // Can be updated later if needed
                                  status: 'pending',
                                  createdAt: DateTime.now(),
                                  userId: userId,
                                );
                                
                                await createOrderUseCase.call(order);

                                // STEP 4: CLEAR CART
                                await _clearCart(userId);

                                // STEP 5: UPDATE REVENUE AFTER ALL PROCESSES ARE COMPLETE
                                // This happens LAST, after order is created and cart is cleared
                                // Use saved cart items data to update revenue
                                await _updateRevenueFromCartItems(cartItemsData);

                                // STEP 6: GO TO PAYMENT
                                context.go(
                                  '/user/cart/qr-payment',
                                  extra: {
                                    'totalAmount': _total,
                                    'orderNumber': _orderNumber,
                                  },
                                );

                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Checkout successful! Order created and revenue updated.',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Checkout',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}