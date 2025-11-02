import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _total = 0.0;
  String _orderNumber = '';

  @override
  void initState() {
    super.initState();
    _generateOrderNumber();
  }

  void _generateOrderNumber() {
    _orderNumber = '225117234425114'; // Tạm thời
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'HLD',
          style: GoogleFonts.montserrat( // <-- Đổi thành GoogleFonts.tên_font
            fontWeight: FontWeight.w800, // Đây là độ dày Black (siêu dày)
            color: Colors.green,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Giỏ hàng trống'));
          }

          final cartItems = snapshot.data!.docs;
          _total = 0.0;
          for (var item in cartItems) {
            final data = item.data() as Map<String, dynamic>;
            final price = (data['price'] as num?)?.toDouble() ?? 0.0;
            final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
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
                    final name = data['name'] ?? 'Sản phẩm';
                    final price = (data['price'] as num?)?.toDouble() ?? 0.0;
                    final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_cart, size: 60),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$quantity x ${price.toStringAsFixed(0)}đ',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _firestore
                                  .collection('cart')
                                  .doc(doc.id)
                                  .delete(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
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
                        const Text('Tổng tiền', style: TextStyle(fontSize: 16)),
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Phí vận chuyển', style: TextStyle(fontSize: 16)),
                        Text('0đ', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_total.toStringAsFixed(0)}đ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _total > 0
                          ? () {
                              context.go(
                                '/user/cart/qr-payment', // ĐÚNG SUB-ROUTE
                                extra: {
                                  'totalAmount': _total,
                                  'orderNumber': _orderNumber,
                                },
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Finish Order',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
