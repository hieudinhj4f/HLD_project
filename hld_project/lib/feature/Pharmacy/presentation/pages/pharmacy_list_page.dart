import 'package:flutter/material.dart';
import 'package:hld_project/feature/Pharmacy/presentation/pages/pharmacy_form_page.dart';
// 1. IMPORT CÁC USECASE VÀ ENTITY
import '../../domain/entity/pharmacy.dart';
import '../../domain/usecase/createPharmacy.dart';
import '../../domain/usecase/deletePharmacy.dart';
import '../../domain/usecase/getAllPharmacy.dart';
import '../../domain/usecase/updatePharmacy.dart';
import '../widgets/pharmacy_card.dart';


class PharmacyListPage extends StatelessWidget {
  // 2. KHAI BÁO CÁC BIẾN USECASE
  final GetAllPharmacy getAllPharmacies;
  final CreatePharmacy createPharmacy;
  final UpdatePharmacy updatePharmacy;
  final DeletePharmacy deletePharmacy;

  // 3. CẬP NHẬT CONSTRUCTOR ĐỂ NHẬN USECASE
  // Đây là bước quan trọng nhất để sửa lỗi "The named parameter ... isn't defined"
  const PharmacyListPage({
    super.key,
    required this.getAllPharmacies,
    required this.createPharmacy,
    required this.updatePharmacy,
    required this.deletePharmacy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pharmacy',
          style: TextStyle(color: Color(0xFF4CAF50)),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      // 4. THAY THẾ LISTVIEW.BUILDER BẰNG FUTUREBUILDER
      body: FutureBuilder<List<Pharmacy>>(
        // Gọi Usecase để lấy dữ liệu thật
        future: getAllPharmacies(),
        builder: (context, snapshot) {
          // Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Trạng thái có lỗi
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Trạng thái không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pharmacies found.'));
          }

          // Trạng thái có dữ liệu
          final pharmacies = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pharmacies.length,
            itemBuilder: (context, index) {
              final pharmacy = pharmacies[index];
              return PharmacyCard(
                pharmacy: pharmacy,
                onEdit: () {
                  // Điều hướng đến trang Form
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PharmacyFormPage(
                        pharmacy: pharmacy,
                        // Bạn cũng nên truyền usecase 'updatePharmacy'
                        // vào trang Form nếu cần
                      ),
                    ),
                  );
                },
                onDelete: () {
                  // Hiển thị dialog xác nhận xóa
                  // Truyền usecase 'deletePharmacy' vào hàm
                  _showDeleteConfirmDialog(context, pharmacy, deletePharmacy);
                },
              );
            },
          );
        },
      ),
      // Bạn có thể thêm nút FloatingActionButton để gọi 'createPharmacy'
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PharmacyFormPage(
                // Truyền null để báo hiệu đây là form TẠO MỚI
                pharmacy: null,
                // Bạn cũng nên truyền 'createPharmacy' vào trang Form
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 5. CẬP NHẬT HÀM DIALOG ĐỂ NHẬN USECASE
  void _showDeleteConfirmDialog(
      BuildContext context,
      Pharmacy pharmacy,
      DeletePharmacy deletePharmacy, // <-- Nhận usecase
      ) {
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
              print('Deleting ${pharmacy.id}...');
              deletePharmacy(pharmacy.id); // <-- GỌI USECASE

              // Tạm thời đóng dialog, lý tưởng nhất là bạn nên
              // refresh lại list (ví dụ dùng Provider/Bloc)
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}