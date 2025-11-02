import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';

class QRPaymentPage extends StatelessWidget {
  final double totalAmount;
  final String orderNumber;

  const QRPaymentPage({
    super.key,
    required this.totalAmount,
    required this.orderNumber,
  });

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin đơn hàng', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Mã đơn hàng: $orderNumber'),
                    const SizedBox(height: 8),
                    Text('Số tiền: ${totalAmount.toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(child: Text('00:36', style: TextStyle(fontSize: 48))),
            const SizedBox(height: 16),
            Center(
              child: QrImageView(
                data: 'Payment: $totalAmount - Order: $orderNumber',
                version: QrVersions.auto,
                size: 200,
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('Verified by Healthy Life Diagnosis')),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.go(
                    '/user/cart/invoice', // ĐÚNG SUB-ROUTE
                    extra: {
                      'totalAmount': totalAmount,
                      'orderNumber': orderNumber,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Xem hóa đơn',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}