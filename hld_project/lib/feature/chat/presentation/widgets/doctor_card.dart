import 'package:flutter/material.dart';
import '../../domain/entities/doctor.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onViewProfile;
  final VoidCallback onAppointment;
  final VoidCallback onChat;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onViewProfile,
    required this.onAppointment,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(doctor.imageUrl),
                  onBackgroundImageError: (_, __) => const Icon(Icons.person),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(doctor.specialty),
                      Text(doctor.degree, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewProfile,
                    child: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAppointment,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Appointment', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}