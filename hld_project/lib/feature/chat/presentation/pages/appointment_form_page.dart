import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/usecases/book_appointment.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/datasources/chat_remote_datasource.dart';

class AppointmentFormPage extends StatefulWidget {
  final String doctorId;
  const AppointmentFormPage({super.key, required this.doctorId});

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _issuesCtrl = TextEditingController();

  late final BookAppointment _bookAppointment;

  @override
  void initState() {
    super.initState();
    final remote = ChatRemoteDataSourceImpl();
    final repo = ChatRepositoryImpl(remote);
    _bookAppointment = BookAppointment(repo);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'doctorId': widget.doctorId,
        'firstName': _firstNameCtrl.text,
        'lastName': _lastNameCtrl.text,
        'email': _emailCtrl.text,
        'phone': _phoneCtrl.text,
        'issues': _issuesCtrl.text,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _bookAppointment.call(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lịch thành công!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lịch hẹn')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(controller: _firstNameCtrl, decoration: const InputDecoration(labelText: 'First Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(labelText: 'Last Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.contains('@') ? null : 'Invalid'),
                TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                TextFormField(controller: _issuesCtrl, decoration: const InputDecoration(labelText: 'Problems'), maxLines: 3),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}