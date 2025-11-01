import 'package:flutter/material.dart';
import '../../domain/usecases/get_doctors.dart';
import '../widgets/doctor_card.dart';
import 'appointment_form_page.dart';
import 'doctor_chat_page.dart';

class ChatHomePage extends StatefulWidget {
  final GetDoctors getDoctors;
  const ChatHomePage({super.key, required this.getDoctors});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  List<dynamic> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final doctors = await widget.getDoctors.call();
    setState(() {
      _doctors = doctors;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HLD', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Doctors, Clinics, Labs',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _doctors[index];
                      return DoctorCard(
                        doctor: doctor,
                        onViewProfile: () {},
                        onAppointment: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppointmentFormPage(doctorId: doctor.id),
                            ),
                          );
                        },
                        onChat: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorChatPage(doctor: doctor),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}