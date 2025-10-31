import 'package:flutter/material.dart';

// 1. IMPORT ENTITY TỪ TẦNG DOMAIN
// Đảm bảo đường dẫn này đúng với cấu trúc của bạn
import '../../domain/entity/pharmacy.dart';

class PharmacyCard extends StatelessWidget {
  // 2. NHẬN DỮ LIỆU LÀ MỘT 'PHARMACY ENTITY'
  final Pharmacy pharmacy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PharmacyCard({
    super.key,
    required this.pharmacy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Giúp bo góc cho cả nội dung bên trong
      child: Stack(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hình ảnh
                SizedBox(
                  width: 120, // Chiều rộng cố định cho ảnh
                  child: Image.asset(
                    // 3. SỬ DỤNG DỮ LIỆU TỪ ENTITY
                    // (Giả sử entity của bạn có trường 'imageUrl')
                    // Bạn nên thêm 1 ảnh placeholder trong assets
                    pharmacy.imageUrl ?? 'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                    // Hiển thị loading hoặc error
                    errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),

                // 2. Thông tin
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // 3. SỬ DỤNG DỮ LIỆU TỪ ENTITY
                          pharmacy.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                            label: 'Destination:', value: pharmacy.destination),
                        _InfoRow(label: 'Hotline:', value: pharmacy.hotline),
                        _InfoRow(label: 'Tax ID:', value: pharmacy.taxId),
                        _InfoRow(
                            label: 'Presentative:',
                            value: pharmacy.presentative),
                        const Spacer(), // Đẩy 2 nút xuống dưới
                        const SizedBox(height: 10),
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
                              backgroundColor: const Color(0xFF4CAF50), // Màu xanh lá
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

          // 3. Cái "bookmark" màu xanh
          Positioned(
            top: -4, // Điều chỉnh để vừa mắt
            right: 8,
            child: Icon(
              Icons.bookmark,
              color: const Color(0xFF1E8A5A), // Màu xanh đậm
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget con để hiển thị 1 dòng thông tin (label + value)
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text.rich(
        TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
          children: [
            TextSpan(
              text: ' $value',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Widget con cho nút Edit/Delete
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