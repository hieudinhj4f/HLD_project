import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hld_project/feature/Pharmacy/presentation/pages/pharmacy_form_page.dart';
// 1. IMPORT CÁC USECASE VÀ ENTITY
import '../../domain/entity/pharmacy.dart';
import '../../domain/usecase/createPharmacy.dart';
import '../../domain/usecase/deletePharmacy.dart';
import '../../domain/usecase/getAllPharmacy.dart';
import '../../domain/usecase/updatePharmacy.dart';
import '../widgets/pharmacy_card.dart';

// --- BƯỚC 1: CHUYỂN THÀNH STATEFULWIDGET ---
class PharmacyListPage extends StatefulWidget {
  // (Constructor vẫn nhận Usecase như cũ)
  final GetAllPharmacy getAllPharmacies;
  final CreatePharmacy createPharmacy;
  final UpdatePharmacy updatePharmacy;
  final DeletePharmacy deletePharmacy;

  const PharmacyListPage({
    super.key,
    required this.getAllPharmacies,
    required this.createPharmacy,
    required this.updatePharmacy,
    required this.deletePharmacy,
  });

  @override
  State<PharmacyListPage> createState() => _PharmacyListPageState();
}

// --- BƯỚC 2: TẠO CLASS STATE ---
class _PharmacyListPageState extends State<PharmacyListPage> {
  // --- BƯỚC 3: KHAI BÁO BIẾN FUTURE TRONG STATE ---
  late Future<List<Pharmacy>> _pharmaciesFuture;

  @override
  void initState() {
    super.initState();
    // --- BƯỚC 4: GỌI FUTURE MỘT LẦN KHI TRANG MỞ ---
    _loadPharmacies();
  }

  // Hàm helper để tải/tải lại
  void _loadPharmacies() {
    setState(() {
      _pharmaciesFuture = widget.getAllPharmacies();
    });
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
      // --- BƯỚC 5: DÙNG BIẾN STATE _pharmaciesFuture ---
      body: FutureBuilder<List<Pharmacy>>(
        future: _pharmaciesFuture, // <-- DÙNG BIẾN NÀY
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pharmacies found.'));
          }

          final pharmacies = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pharmacies.length,
            itemBuilder: (context, index) {
              final pharmacy = pharmacies[index];
              return PharmacyCard(
                pharmacy: pharmacy,
                onEdit: () {
                  // --- BƯỚC 6: SỬA 'onEdit' (async/await) ---
                  _navigateToForm(pharmacy: pharmacy);
                },
                onDelete: () {
                  _showDeleteConfirmDialog(context, pharmacy, widget.deletePharmacy);
                },
              );
            },
          );
        },
      ),
      // --- BƯỚC 7: SỬA 'floatingActionButton' (async/await) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToForm(pharmacy: null); // Chế độ Add
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Hàm helper để điều hướng (tránh lặp code)
  void _navigateToForm({Pharmacy? pharmacy}) async {
    // Chuyển sang async
    // Đợi trang Form đóng lại
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PharmacyFormPage(
          pharmacy: pharmacy, // (null cho Add, có data cho Edit)
          createPharmacy: widget.createPharmacy,
          updatePharmacy: widget.updatePharmacy,
        ),
      ),
    );

    // SAU KHI QUAY LẠI, GỌI LẠI FUTURE ĐỂ CẬP NHẬT UI
    _loadPharmacies();
  }

  // --- BƯỚC 8: SỬA HÀM XÓA (async/await) ---
  void _showDeleteConfirmDialog(
      BuildContext context,
      Pharmacy pharmacy,
      DeletePharmacy deletePharmacy,
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
            onPressed: () async { // <-- Sửa thành async
              print('Deleting ${pharmacy.id}...');

              try {
                await deletePharmacy(pharmacy.id); // <-- Sửa (await)

                // Đóng dialog (kiểm tra mounted vì là async)
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }

                // SAU KHI XÓA, GỌI LẠI FUTURE ĐỂ CẬP NHẬT UI
                _loadPharmacies();

              } catch (e) {
                // Xử lý lỗi nếu xóa thất bại
                print('Delete failed: $e');
                // (Bạn có thể hiển thị SnackBar ở đây)
              }
            },
          ),
        ],
      ),
    );
  }
}