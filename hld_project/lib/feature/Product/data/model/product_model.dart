import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/product/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.categories,
    required super.imageUrl,
    required super.price,
    required super.quantity,
    required super.pharmacyId,
    required super.sold,
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
      pharmacyId: data['pharmacyId'] ?? '',
      sold: data['sold'] ?? 0,// ✅
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updateAt: data['updateAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      categories: product.categories,
      imageUrl: product.imageUrl,
      price: product.price,
      quantity: product.quantity,
      pharmacyId: product.pharmacyId,
      sold: product.sold,
      createdAt: product.createdAt,
      updateAt: product.updateAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'categories': categories,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'pharmacyId': pharmacyId,
      'sold': sold,
      'createdAt': createdAt,
      'updateAt': updateAt,
    };
  }

  // --- PHẦN BỔ SUNG ---
  // Chuyển Model (tầng Data) thành Entity (tầng Domain)
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      categories: categories,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity,
      pharmacyId: pharmacyId,
      sold: sold,
      createdAt: createdAt,
      updateAt: updateAt,
    );
  }
}