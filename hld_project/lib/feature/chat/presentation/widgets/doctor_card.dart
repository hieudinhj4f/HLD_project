import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // === ẢNH BÁC SĨ ===
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                doctor.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // === THÔNG TIN ===
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialty,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${doctor.averageRating.toStringAsFixed(1)} (${doctor.totalReviews})',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // === 3 NÚT ===
            Column(
              children: [
                // View Profile
                OutlinedButton(
                  onPressed: onViewProfile,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(100, 36),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'View Profile',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 6),

                // Appointment + Chat (cùng hàng)
                Row(
                  children: [
                    // Appointment
                    ElevatedButton(
                      onPressed: onAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Appointment',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Chat
                    IconButton(
                      onPressed: onChat,
                      icon: const Icon(Icons.message, color: Colors.green),
                      tooltip: 'Chat',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
