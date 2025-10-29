import '../../domain/entity/recipe.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entity/recipe.dart';// Import Recipe Entity

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap; // Xử lý khi nhấn vào xem chi tiết/sửa
  final VoidCallback onDeletePressed; // Xử lý khi nhấn nút xóa

  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.onTap,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2.0,
      clipBehavior: Clip.antiAlias, // Cắt góc tròn
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap, // Gọi hàm onTap đã truyền vào
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hình ảnh
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  recipe.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  // Hiển thị placeholder khi lỗi
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Iconsax.gallery, color: Colors.grey),
                    );
                  },
                  // Hiển thị loading
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // 2. Thông tin (Tên, Thể loại, Thời gian)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Hàng chứa Thể loại và Thời gian
                    Row(
                      children: [
                        // Thể loại (Category)
                        Chip(
                          label: Text(recipe.category),
                          backgroundColor: Colors.blue.shade50,
                          labelStyle: TextStyle(color: Colors.blue.shade800, fontSize: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        // Thời gian (Time)
                        Icon(Iconsax.clock, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.time} phút',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 3. Nút Xóa
              IconButton(
                icon: const Icon(Iconsax.trash, color: Colors.red),
                onPressed: onDeletePressed, // Gọi hàm onDeletePressed đã truyền vào
                tooltip: 'Xóa',
              ),
            ],
          ),
        ),
      ),
    );
  }
}