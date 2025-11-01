import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InvoicePage extends StatelessWidget {
  final double totalAmount;
  final String orderNumber;

  const InvoicePage({
    super.key,
    required this.totalAmount,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Hóa đơn'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const Text('Thanh toán thành công', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text('Mã hóa đơn: $orderNumber'),
            Text('31/10/2025, 17:50PM'),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.account_balance),
                const SizedBox(width: 8),
                const Text('SCB'),
                const SizedBox(width: 8),
                const Text('XXX-XXX675-2'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.payment),
                const SizedBox(width: 8),
                const Text('VNPay'),
                const SizedBox(width: 8),
                const Text('XXX-XXX675-2'),
              ],
            ),
            const SizedBox(height: 24),
            Text('Tổng cộng: ${totalAmount.toStringAsFixed(0)}đ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}