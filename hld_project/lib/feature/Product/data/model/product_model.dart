// lib/features/product/data/models/product_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/product/product.dart'; // Import lớp cha Product

class ProductModel extends Product {
  // 1. Constructor: BỎ 'const' và gọi constructor của lớp cha
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.categories,
    required super.imageUrl,
    required super.price,
    required super.quantity,
    required super.createdAt,
    required super.updateAt,

  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      categories: data['categories'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] ?? 0,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updateAt: data['updateAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      categories: categories,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity,
      createdAt: createdAt,
      updateAt: updateAt,
    );
  }
}