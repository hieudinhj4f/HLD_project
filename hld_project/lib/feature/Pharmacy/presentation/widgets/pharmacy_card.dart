// presentation/widgets/pharmacy_card.dart
import 'package:flutter/material.dart';
import '../../domain/entity/pharmacy.dart';

class PharmacyCard extends StatelessWidget {
  final Pharmacy pharmacy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete; // ĐÃ SỬA: VoidCallback? (không có >)

  const PharmacyCard({
    super.key,
    required this.pharmacy,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: pharmacy.imageUrl != null
              ? NetworkImage(pharmacy.imageUrl!)
              : const AssetImage('assets/images/pharmacy_placeholder.png') as ImageProvider,
          radius: 24,
        ),
        title: Text(
          pharmacy.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pharmacy.address != null)
              Text(pharmacy.address!, style: const TextStyle(fontSize: 13)),
            if (pharmacy.phone != null)
              Text(pharmacy.phone!, style: const TextStyle(fontSize: 13)),
            Text(
              '${pharmacy.staffCount} nhân viên',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trạng thái hoạt động
            Icon(
              Icons.circle,
              color: pharmacy.isActive ? Colors.green : Colors.red,
              size: 12,
            ),
            const SizedBox(width: 8),

            // Nút Edit
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              tooltip: 'Sửa',
            ),

            // Nút Delete (với confirm dialog)
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: onDelete != null
                  ? () => _showDeleteConfirm(context)
                  : null,
              tooltip: 'Xóa',
            ),
          ],
        ),
      ),
    );
  }

  // === XÁC NHẬN XÓA ===
  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa nhà thuốc?'),
        content: Text('Bạn có chắc muốn xóa "${pharmacy.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              onDelete?.call(); // Gọi callback xóa
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}