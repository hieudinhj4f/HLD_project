import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/doctor.dart'; // Đảm bảo đường dẫn này đúng

// 1. IMPORT CÁC USECASE
import '../../domain/usecases/create_doctor.dart';
import '../../domain/usecases/update_doctor.dart';


class DoctorFormPage extends StatefulWidget {
  final Doctor? doctor;

  // 2. NHẬN CÁC USECASE
  final CreateDoctor createDoctor;
  final UpdateDoctor updateDoctor;

  const DoctorFormPage({
    super.key,
    this.doctor,
    required this.createDoctor,
    required this.updateDoctor,
  });

  @override
  State<DoctorFormPage> createState() => _DoctorFormPageState();
}

class _DoctorFormPageState extends State<DoctorFormPage> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditMode;
  bool _isLoading = false; // Thêm biến để quản lý trạng thái loading

  // (Khai báo 14 controllers - Giữ nguyên)
  late final TextEditingController _nameController;
  late final TextEditingController _specialtyController;
  late final TextEditingController _degreeController;
  late final TextEditingController _typeController;
  late final TextEditingController _experienceYearsController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _totalExaminationsController;
  late final TextEditingController _accurateRateController;
  late final TextEditingController _averageRatingController;
  late final TextEditingController _totalReviewsController;
  late final TextEditingController _totalConsultationsController;
  late final TextEditingController _onlineHoursController;
  late final TextEditingController _responseRateController;
  late final TextEditingController _activeDaysController;

  @override
  void initState() {
    super.initState();
    _isEditMode = (widget.doctor != null);

    // (Khởi tạo 14 controllers - Giữ nguyên)
    _nameController = TextEditingController(text: widget.doctor?.name ?? '');
    _specialtyController =
        TextEditingController(text: widget.doctor?.specialty ?? '');
    _degreeController = TextEditingController(text: widget.doctor?.degree ?? '');
    _typeController = TextEditingController(text: widget.doctor?.type ?? '');
    _experienceYearsController = TextEditingController(
        text: widget.doctor?.experienceYears.toString() ?? '0');
    _imageUrlController =
        TextEditingController(text: widget.doctor?.imageUrl ?? '');
    _totalExaminationsController = TextEditingController(
        text: widget.doctor?.totalExaminations.toString() ?? '0');
    _accurateRateController = TextEditingController(
        text: widget.doctor?.accurateRate.toString() ?? '0.0');
    _averageRatingController = TextEditingController(
        text: widget.doctor?.averageRating.toString() ?? '0.0');
    _totalReviewsController = TextEditingController(
        text: widget.doctor?.totalReviews.toString() ?? '0');
    _totalConsultationsController = TextEditingController(
        text: widget.doctor?.totalConsultations.toString() ?? '0');
    _onlineHoursController = TextEditingController(
        text: widget.doctor?.onlineHours.toString() ?? '0');
    _responseRateController = TextEditingController(
        text: widget.doctor?.responseRate.toString() ?? '0.0');
    _activeDaysController = TextEditingController(
        text: widget.doctor?.activeDays.toString() ?? '0');
  }

  @override
  void dispose() {
    // (Dispose 14 controllers - Giữ nguyên)
    _nameController.dispose();
    _specialtyController.dispose();
    _degreeController.dispose();
    _typeController.dispose();
    _experienceYearsController.dispose();
    _imageUrlController.dispose();
    _totalExaminationsController.dispose();
    _accurateRateController.dispose();
    _averageRatingController.dispose();
    _totalReviewsController.dispose();
    _totalConsultationsController.dispose();
    _onlineHoursController.dispose();
    _responseRateController.dispose();
    _activeDaysController.dispose();
    super.dispose();
  }

  // 3. VIẾT LẠI HOÀN TOÀN HÀM _onSave
  void _onSave() async {
    // Kiểm tra form hợp lệ
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Nếu đang loading thì không làm gì cả
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // A. Thu thập và Phân tích (Parse) dữ liệu
      final doctorData = Doctor(
        id: widget.doctor?.id ?? '', // Dùng ID cũ nếu 'Edit'
        name: _nameController.text,
        specialty: _specialtyController.text,
        degree: _degreeController.text,
        type: _typeController.text,
        experienceYears: int.tryParse(_experienceYearsController.text) ?? 0,
        imageUrl: _imageUrlController.text,
        totalExaminations: int.tryParse(_totalExaminationsController.text) ?? 0,
        accurateRate: double.tryParse(_accurateRateController.text) ?? 0.0,
        averageRating: double.tryParse(_averageRatingController.text) ?? 0.0,
        totalReviews: int.tryParse(_totalReviewsController.text) ?? 0,
        totalConsultations: int.tryParse(_totalConsultationsController.text) ?? 0,
        onlineHours: int.tryParse(_onlineHoursController.text) ?? 0,
        responseRate: double.tryParse(_responseRateController.text) ?? 0.0,
        activeDays: int.tryParse(_activeDaysController.text) ?? 0,
      );

      // B. Quyết định gọi Usecase nào
      if (_isEditMode) {
        // Chế độ Cập nhật
        await widget.updateDoctor(doctorData);
      } else {
        // Chế độ Tạo mới
        await widget.createDoctor(doctorData);
      }

      // C. Quay lại trang trước (nếu thành công)
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // D. Xử lý lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save doctor: $e')),
        );
      }
    } finally {
      // Dừng loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Doctor' : 'Add Doctor'),
        actions: [
          // Hiển thị loading hoặc nút save
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Iconsax.save_2),
              onPressed: _onSave,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- (Toàn bộ 14 TextFormField giữ nguyên) ---
              _buildTextFormField(
                controller: _nameController,
                label: 'Doctor Name',
                icon: Iconsax.user,
              ),
              _buildTextFormField(
                controller: _imageUrlController,
                label: 'Image URL',
                icon: Iconsax.gallery,
                keyboardType: TextInputType.url,
              ),
              _buildTextFormField(
                controller: _specialtyController,
                label: 'Specialty',
                icon: Iconsax.health,
              ),
              _buildTextFormField(
                controller: _degreeController,
                label: 'Degree (e.g., MD, PhD)',
                icon: Iconsax.award,
              ),
              _buildTextFormField(
                controller: _typeController,
                label: 'Type (e.g., Online, Offline)',
                icon: Iconsax.monitor,
              ),
              const SizedBox(height: 24),
              _buildTextFormField(
                controller: _experienceYearsController,
                label: 'Experience (Years)',
                icon: Iconsax.briefcase,
                keyboardType: TextInputType.number,
              ),
              _buildTextFormField(
                controller: _totalExaminationsController,
                label: 'Total Examinations',
                icon: Iconsax.activity,
                keyboardType: TextInputType.number,
              ),
              _buildTextFormField(
                controller: _accurateRateController,
                label: 'Accurate Rate (0.0 - 100.0)',
                icon: Iconsax.percentage_circle,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),
              _buildTextFormField(
                controller: _averageRatingController,
                label: 'Average Rating (0.0 - 5.0)',
                icon: Iconsax.star,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              _buildTextFormField(
                controller: _totalReviewsController,
                label: 'Total Reviews',
                icon: Iconsax.messages_2,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              _buildTextFormField(
                controller: _totalConsultationsController,
                label: 'Total Consultations',
                icon: Iconsax.message_text,
                keyboardType: TextInputType.number,
              ),
              _buildTextFormField(
                controller: _onlineHoursController,
                label: 'Online Hours (Total)',
                icon: Iconsax.clock,
                keyboardType: TextInputType.number,
              ),
              _buildTextFormField(
                controller: _responseRateController,
                label: 'Response Rate (0.0 - 100.0)',
                icon: Iconsax.percentage_square,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              _buildTextFormField(
                controller: _activeDaysController,
                label: 'Active Days (Total)',
                icon: Iconsax.calendar_1,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              // Nút Save
              ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Iconsax.save_2),
                label: Text(_isLoading
                    ? 'Saving...'
                    : (_isEditMode ? 'Save Changes' : 'Add Doctor')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                // Chặn nhấn nút nếu đang loading
                onPressed: _isLoading ? null : _onSave,
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- (Hàm helper _buildTextFormField giữ nguyên) ---
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: (keyboardType == TextInputType.number ||
            keyboardType.decimal == true)
            ? <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ]
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}