import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entity/product/product.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  Future<void> _addToCart() async {
    await FirebaseFirestore.instance.collection('cart').add({
      'productId': widget.product.id,
      'name': widget.product.name,
      'price': widget.product.price,
      'quantity': quantity,
      'imageUrl': widget.product.imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.product.imageUrl,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.product.description),
            const SizedBox(height: 16),
            Text(
              '${widget.product.price.toInt()}đ / Viên',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Chọn số lượng', style: TextStyle(fontSize: 16)),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(
                        () => quantity = quantity > 1 ? quantity - 1 : 1,
                  ),
                  icon: const Icon(Icons.remove),
                ),
                Text('$quantity', style: const TextStyle(fontSize: 18)),
                IconButton(
                  onPressed: () => setState(() => quantity++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Chọn mua',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
