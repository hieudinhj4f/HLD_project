// lib/features/products/presentation/widgets/product_card.dart

import 'package:flutter/material.dart';
import '../../../domain/entity/product/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDetailsPressed; // Callback khi nhấn nút xem chi tiết
  final VoidCallback onDeletePressed;
  const ProductCard({
    Key? key,
    required this.product,
    required this.onDetailsPressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: Colors.blue, width: 1.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16.0),

            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    // Có thể thêm thuộc tính packInfo vào Product model nếu muốn hiển thị
                    // Hoặc lấy từ description và xử lý
                    '${product.quantity} viên x ${product.price ~/ product.quantity}đ/ viên', // Giả sử price là tổng giá, quantity là tổng số viên
                    // Hoặc đơn giản hơn: '10 vỉ x 10 viên' như trong hình
                    // Nếu muốn hiển thị như hình, bạn có thể thêm một thuộc tính 'packInfo' vào Product model
                    // Ví dụ: '10 vỉ x 10 viên'
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${_formatPrice(product.price)}đ/ viên', // Giả sử price là giá 1 viên
                    // Nếu price là tổng giá 1 pack, bạn sẽ cần tính toán lại
                    // Hoặc thêm thuộc tính unitPrice vào Product model
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey, // Màu xám như hình
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Nút "Open" / "Xem chi tiết"
            Column( // Thay đổi từ Align thành Column để chứa nhiều nút
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 1. Nút "Open" / "Xem chi tiết"
                ElevatedButton(
                  onPressed: onDetailsPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                    minimumSize: const Size(80, 35), // Đặt kích thước tối thiểu
                  ),
                  child: const Text('Open', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 8),

                // 2. Nút XÓA
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDeletePressed, // <--- SỬ DỤNG CALLBACK XÓA
                  visualDensity: VisualDensity.compact, // Giảm kích thước vùng chạm
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hàm định dạng giá tiền (ví dụ: thêm dấu phẩy)
  String _formatPrice(double price) {
    // Có thể sử dụng intl package để định dạng tiền tệ chuyên nghiệp hơn
    // Ở đây chỉ là ví dụ đơn giản
    return price.toStringAsFixed(0); // Không hiển thị số lẻ
  }
}