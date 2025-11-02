import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/doctor.dart'; // Đảm bảo đường dẫn này đúng

class DoctorFormPage extends StatefulWidget {
  // Nếu 'doctor' là null, đây là form 'Tạo mới'
  // Nếu 'doctor' có dữ liệu, đây là form 'Chỉnh sửa'
  final Doctor? doctor;

  const DoctorFormPage({
    super.key,
    this.doctor
  });

  @override
  State<DoctorFormPage> createState() => _DoctorFormPageState();
}

class _DoctorFormPageState extends State<DoctorFormPage> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditMode;

  // 1. Khai báo controllers cho TẤT CẢ các trường
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

    // 2. Khởi tạo giá trị cho controllers
    // Nếu là 'Edit', điền thông tin cũ. Nếu là 'Add', điền giá trị mặc định.
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
    // 3. Luôn dispose controllers
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

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      // 4. Thu thập dữ liệu
      // Bạn sẽ cần gọi Usecase 'createDoctor' hoặc 'updateDoctor' ở đây
      // Dữ liệu đã có sẵn trong các controllers, ví dụ:
      final String name = _nameController.text;
      final int experienceYears =
          int.tryParse(_experienceYearsController.text) ?? 0;
      final double averageRating =
          double.tryParse(_averageRatingController.text) ?? 0.0;

      print('Saving Doctor: $name');
      print('Experience: $experienceYears years');
      print('Rating: $averageRating');

      // Tạm thời chỉ quay lại trang trước
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Doctor' : 'Add Doctor'),
        actions: [
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
              // --- NHÓM THÔNG TIN CƠ BẢN ---
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

              // --- NHÓM KINH NGHIỆM VÀ CHỈ SỐ ---
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

              // --- NHÓM ĐÁNH GIÁ ---
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

              // --- NHÓM HOẠT ĐỘNG ONLINE ---
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
              ElevatedButton.icon(
                icon: const Icon(Iconsax.save_2),
                label: Text(_isEditMode ? 'Save Changes' : 'Add Doctor'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF4CAF50), // Màu xanh lá
                  foregroundColor: Colors.white,
                ),
                onPressed: _onSave,
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget con để tạo TextFormField cho gọn
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
        // Thêm bộ lọc cho đầu vào số
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