import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hld_project/feature/chat/presentation/pages/doctor_form_page.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/usecases/create_doctor.dart';
import '../../domain/usecases/delete_doctor.dart';
// Bạn import 2 Usecase lấy Bác sĩ, 'get_all_doctor.dart' và 'get_doctors.dart'
// Tôi sẽ dùng 'GetAllDoctor' theo khai báo biến của bạn
import '../../domain/usecases/get_all_doctor.dart';
import '../../domain/usecases/update_doctor.dart';
// Bạn cần import DoctorCard cho admin (tôi đoán tên)
import 'package:hld_project/feature/chat/presentation/widgets/doctor_card_admin.dart';

// --- BƯỚC 1: CHUYỂN THÀNH STATEFULWIDGET ---
class DoctorListPage extends StatefulWidget {
  final GetAllDoctor getAllDoctors;
  final CreateDoctor createDoctor;
  final UpdateDoctor updateDoctor;
  final DeleteDoctor deleteDoctor;

  const DoctorListPage({
    super.key,
    required this.getAllDoctors,
    required this.createDoctor,
    required this.updateDoctor,
    required this.deleteDoctor,
  });

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

// --- BƯỚC 2: TẠO CLASS STATE ---
class _DoctorListPageState extends State<DoctorListPage> {
  // --- BƯỚC 3: KHAI BÁO BIẾN FUTURE TRONG STATE ---
  late Future<List<Doctor>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    // --- BƯỚC 4: GỌI FUTURE MỘT LẦN KHI TRANG MỞ ---
    _loadDoctors();
  }

  // Hàm helper để tải/tải lại
  void _loadDoctors() {
    setState(() {
      _doctorsFuture = widget.getAllDoctors(); // Gọi Usecase từ widget
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
      // --- BƯỚC 5: DÙNG BIẾN STATE _doctorsFuture ---
      body: FutureBuilder<List<Doctor>>(
        future: _doctorsFuture, // <-- DÙNG BIẾN NÀY
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No doctors found.'));
          }

          final doctors = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              // Đổi tên DoctorCard cho đúng (bạn import là DoctorCard)
              return DoctorCard(
                doctor: doctor,
                onEdit: () {
                  // --- BƯỚC 6: SỬA 'onEdit' (gọi hàm helper) ---
                  _navigateToForm(doctor: doctor);
                },
                onDelete: () {
                  // Gọi hàm dialog (truyền usecase từ widget)
                  _showDeleteConfirmDialog(context, doctor, widget.deleteDoctor);
                },
              );
            },
          );
        },
      ),
      // --- BƯỚC 7: SỬA 'floatingActionButton' (gọi hàm helper) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToForm(doctor: null); // Chế độ Add
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Hàm helper để điều hướng (tránh lặp code)
  void _navigateToForm({Doctor? doctor}) async {
    // Chuyển sang async
    // Đợi trang Form đóng lại
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DoctorFormPage(
          doctor: doctor, // (null cho Add, có data cho Edit)
          createDoctor: widget.createDoctor,
          updateDoctor: widget.updateDoctor,
        ),
      ),
    );

    // SAU KHI QUAY LẠI, GỌI LẠI FUTURE ĐỂ CẬP NHẬT UI
    _loadDoctors();
  }

  // --- BƯỚC 8: SỬA HÀM XÓA (async/await) ---
  void _showDeleteConfirmDialog(
      BuildContext context,
      Doctor doctor,
      DeleteDoctor deleteDoctor,
      ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete Dr. ${doctor.name}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () async { // <-- Sửa thành async
              print('Deleting ${doctor.id}...');

              try {
                await deleteDoctor(doctor.id); // <-- Sửa (await)

                // Đóng dialog (kiểm tra mounted vì là async)
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }

                // SAU KHI XÓA, GỌI LẠI FUTURE ĐỂ CẬP NHẬT UI
                _loadDoctors();

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