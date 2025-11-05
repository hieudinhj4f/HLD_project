// lib/features/products/presentation/widgets/product_card.dart

import 'package:flutter/material.dart';
import '../../../domain/entity/product/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDetailsPressed; // Callback when the details button is pressed
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
            // Product image
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

            // Product information
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
                    // Can add a packInfo attribute to the Product model if desired
                    // Or get from description and process it
                    '${product.quantity} units x ${product.price ~/ product.quantity}đ/ unit', // Assuming price is total price, quantity is total units
                    // Or simpler: '10 blisters x 10 tablets' as in the image
                    // If you want to display it like the image, you can add a 'packInfo' attribute to the Product model
                    // Example: '10 blisters x 10 tablets'
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${_formatPrice(product.price)}đ/ unit', // Assuming price is the price per unit
                    // If price is the total price for 1 pack, you will need to recalculate
                    // Or add a unitPrice attribute to the Product model
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey, // Gray color like in the image
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // "Open" / "View details" button
            Column( // Changed from Align to Column to hold multiple buttons
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 1. "Open" / "View details" button
                ElevatedButton(
                  onPressed: onDetailsPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                    minimumSize: const Size(80, 35), // Set minimum size
                  ),
                  child: const Text('Open', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 8),

                // 2. DELETE Button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDeletePressed, // <--- USE DELETE CALLBACK
                  visualDensity: VisualDensity.compact, // Reduce the tap target size
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Price formatting function (e.g., add commas)
  String _formatPrice(double price) {
    // Can use the intl package for more professional currency formatting
    // This is just a simple example
    return price.toStringAsFixed(0); // Do not display decimal places
  }
}