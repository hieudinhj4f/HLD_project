import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String categories;
  final String imageUrl;
  final double price;
  final int quantity;
  final String pharmacyId;
  final int sold;
  final Timestamp createdAt;
  final Timestamp updateAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.pharmacyId,
    required this.sold,
    Timestamp? createdAt,
    Timestamp? updateAt,
  })  : createdAt = createdAt ?? Timestamp.now(),
        updateAt = updateAt ?? Timestamp.now();

  // 🔹 Nếu bạn có toMap và fromMap:
  Map<String, dynamic> toMap() {
    return {
      'id': id,
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

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      categories: map['categories'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      pharmacyId: map['pharmacyId'] ?? '',
      sold: (map['sold'] ?? 0).toInt(),
      createdAt: map['createdAt'],
      updateAt: map['updateAt'],
    );
  }
}
