import 'package:flutter/material.dart';
import 'package:hld_project/feature/Pharmacy/presentation/pages/pharmacy_form_page.dart';
import '../../domain/entity/pharmacy.dart';
import '../widgets/pharmacy_card.dart';

// Dữ liệu giả lập
final List<Pharmacy> mockPharmacies = [
  Pharmacy(
    id: '1',
    name: "KIM ANH'S PHARMACY",
    destination: '16 Hoan Kiem Distric, Ha Noi',
    hotline: '1900 9090',
    taxId: '0XX0 XXX0 X0X0',
    presentative: 'Nguyen Van A',
    imageUrl: 'assets/images/pharmacy_image.png', // <-- Bạn cần thêm ảnh này
  ),
  Pharmacy(
    id: '2',
    name: 'PHARMACITY PHARMACY',
    destination: '12 Ba Truc Distric, Ha Noi',
    hotline: '1800 0090',
    taxId: '0XX0 XXX0 X0X0',
    presentative: 'Nguyen Van B',
    imageUrl: 'assets/images/pharmacity_image.png', // <-- Thêm ảnh này
  ),
];

class PharmacyListPage extends StatelessWidget {
  const PharmacyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền nhạt
      // Ghi chú: Tôi bỏ qua 'AppBar' vì 'AppShell' của bạn đã quản lý
      // tiêu đề và thanh điều hướng rồi.
      // Nếu bạn muốn có AppBar riêng, hãy thêm nó vào đây.
      // Ví dụ:
      appBar: AppBar(
        title: const Text(
          'Pharmacy',
          style: TextStyle(color: Color(0xFF4CAF50)),
        ),
        // Dòng này rất quan trọng để bỏ mũi tên back,
        // vì đây là 1 trang tab chính
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockPharmacies.length,
        itemBuilder: (context, index) {
          final pharmacy = mockPharmacies[index];
          return PharmacyCard(
            pharmacy: pharmacy,
            onEdit: () {
              // Điều hướng đến trang Form
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PharmacyFormPage(pharmacy: pharmacy),
                ),
              );
            },
            onDelete: () {
              // Hiển thị dialog xác nhận xóa
              _showDeleteConfirmDialog(context, pharmacy);
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Pharmacy pharmacy) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${pharmacy.name}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              // Gọi Usecase/Provider để xóa ở đây
              print('Deleting ${pharmacy.name}...');
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}