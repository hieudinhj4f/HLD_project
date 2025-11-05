import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/doctor.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image
            SizedBox(
              width: 110,
              child: Image.network(
                doctor.imageUrl,
                fit: BoxFit.cover,
                // Fallback image on load error
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Iconsax.user, color: Colors.grey, size: 50),
                  ),
                ),
                // Image while loading
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),

            // 2. Information
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${doctor.specialty} - ${doctor.degree}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Row 1: Rating & Experience
                    Row(
                      children: [
                        _InfoChip(
                          icon: Iconsax.star,
                          text: '${doctor.averageRating} (${doctor.totalReviews})',
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Iconsax.briefcase,
                          text: '${doctor.experienceYears} Yrs Exp', // <-- Translated
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 2: Stats
                    _InfoChip(
                      icon: Iconsax.activity,
                      text: '${doctor.totalExaminations} consultations', // <-- Translated
                      color: Colors.grey[600]!,
                    ),

                    const Spacer(), // Push buttons to the bottom

                    // 3. Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _ActionButton(
                          text: 'Edit',
                          color: Colors.grey[700]!,
                          backgroundColor: Colors.grey[200]!,
                          onPressed: onEdit,
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          text: 'Delete',
                          color: Colors.white,
                          backgroundColor: Colors.red[600]!,
                          onPressed: onDelete,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Child widget for info chips (Rating, Experience)
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Child widget for Edit/Delete buttons (Identical to PharmacyCard)
class _ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.text,
    required this.color,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}