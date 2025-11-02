import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hld_project/feature/chat/presentation/pages/doctor_form_page.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/usecases/create_doctor.dart';
import '../../domain/usecases/delete_doctor.dart';
import '../../domain/usecases/get_all_doctor.dart';
import '../../domain/usecases/get_doctors.dart';
import '../../domain/usecases/update_doctor.dart';
import 'package:hld_project/feature/chat/presentation/widgets/doctor_card_admin.dart';

class DoctorListPage extends StatelessWidget {
  // 1. NHẬN CÁC USECASE (từ AppRouter)
  // (Lưu ý: Tên Usecase phải khớp với file Usecase của bạn)
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

      // 2. DÙNG FUTUREBUILDER ĐỂ LẤY DỮ LIỆU
      body: FutureBuilder<List<Doctor>>(
        future: getAllDoctors(), // Gọi Usecase
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

          // 3. HIỂN THỊ DANH SÁCH
          final doctors = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return DoctorCard(
                doctor: doctor,
                onEdit: () {
                  // 4. ĐIỀU HƯỚNG SANG TRANG FORM (CHẾ ĐỘ EDIT)
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DoctorFormPage(
                        doctor: doctor,
                        // Bạn cũng nên truyền 'updateDoctor' vào đây
                      ),
                    ),
                  );
                },
                onDelete: () {
                  // 5. GỌI DIALOG XÁC NHẬN XÓA
                  _showDeleteConfirmDialog(context, doctor, deleteDoctor);
                },
              );
            },
          );
        },
      ),

      // 6. NÚT THÊM MỚI
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ĐIỀU HƯỚNG SANG TRANG FORM (CHẾ ĐỘ ADD)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DoctorFormPage(
                doctor: null, // Truyền 'null' để báo là form Add
                // Bạn cũng nên truyền 'createDoctor' vào đây
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 7. HÀM XÁC NHẬN XÓA
  void _showDeleteConfirmDialog(
      BuildContext context,
      Doctor doctor,
      DeleteDoctor deleteDoctor, // Nhận Usecase
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
            onPressed: () {
              // GỌI USECASE ĐỂ XÓA
              print('Deleting ${doctor.id}...');
              deleteDoctor(doctor.id);

              // (Lý tưởng nhất là bạn nên refresh lại list,
              // tạm thời chỉ đóng dialog)
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}