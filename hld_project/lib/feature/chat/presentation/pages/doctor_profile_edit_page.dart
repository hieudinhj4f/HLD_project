import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';
import '../../data/models/doctor_model.dart';
import '../../domain/entities/doctor.dart';

class DoctorProfileEditPage extends StatefulWidget {
  const DoctorProfileEditPage({super.key});

  @override
  State<DoctorProfileEditPage> createState() => _DoctorProfileEditPageState();
}

class _DoctorProfileEditPageState extends State<DoctorProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _specialtyController;
  late TextEditingController _degreeController;
  late TextEditingController _typeController;
  late TextEditingController _experienceController;
  late TextEditingController _imageUrlController;

  Doctor? _existingDoctor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _specialtyController = TextEditingController();
    _degreeController = TextEditingController();
    _typeController = TextEditingController();
    _experienceController = TextEditingController();
    _imageUrlController = TextEditingController();

    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userId)
          .get();

      if (doc.exists) {
        setState(() {
          _existingDoctor = DoctorModel.fromFirestore(doc);
          _nameController.text = _existingDoctor!.name;
          _specialtyController.text = _existingDoctor!.specialty;
          _degreeController.text = _existingDoctor!.degree;
          _typeController.text = _existingDoctor!.type;
          _experienceController.text = _existingDoctor!.experienceYears.toString();
          _imageUrlController.text = _existingDoctor!.imageUrl;
        });
      }
    } catch (e) {
      debugPrint('Error loading doctor data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _degreeController.dispose();
    _typeController.dispose();
    _experienceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final doctorModel = DoctorModel(
        id: userId,
        name: _nameController.text.trim(),
        specialty: _specialtyController.text.trim(),
        degree: _degreeController.text.trim(),
        type: _typeController.text.trim(),
        experienceYears: int.tryParse(_experienceController.text) ?? 0,
        imageUrl: _imageUrlController.text.trim(),
        totalExaminations: _existingDoctor?.totalExaminations ?? 0,
        accurateRate: _existingDoctor?.accurateRate ?? 0.0,
        averageRating: _existingDoctor?.averageRating ?? 0.0,
        totalReviews: _existingDoctor?.totalReviews ?? 0,
        totalConsultations: _existingDoctor?.totalConsultations ?? 0,
        onlineHours: _existingDoctor?.onlineHours ?? 0,
        responseRate: _existingDoctor?.responseRate ?? 0.0,
        activeDays: _existingDoctor?.activeDays ?? 0,
      );

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userId)
          .set(doctorModel.toJson(), SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
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
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.green.withOpacity(0.1),
                      backgroundImage: _imageUrlController.text.isNotEmpty
                          ? NetworkImage(_imageUrlController.text)
                          : null,
                      child: _imageUrlController.text.isEmpty
                          ? const Icon(Icons.person, size: 60, color: Colors.green)
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Fields
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Specialty *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                  hintText: 'e.g., Cardiology, Pediatrics',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your specialty';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _degreeController,
                decoration: const InputDecoration(
                  labelText: 'Degree *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                  hintText: 'e.g., MD, MBBS',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your degree';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                  hintText: 'e.g., General Practitioner',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter doctor type';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: 'Years of Experience *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter years of experience';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Profile Image URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  hintText: 'https://example.com/image.jpg',
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Profile',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

