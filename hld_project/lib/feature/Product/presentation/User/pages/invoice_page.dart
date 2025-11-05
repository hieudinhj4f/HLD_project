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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Invoice'), // <-- Đã dịch
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const Text(
              'Payment Successful', // <-- Đã dịch
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text('Invoice Code: $orderNumber'), // <-- Đã dịch
            Text('31/10/2025, 17:50PM'), // (Giữ nguyên ngày giờ ví dụ)
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
            Text(
              'Total: ${totalAmount.toStringAsFixed(0)}đ', // <-- Đã dịch
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'), // <-- Đã dịch
            ),
          ],
        ),
      ),
    );
  }
}