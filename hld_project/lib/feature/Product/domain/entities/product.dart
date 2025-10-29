import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String categories;
  final String imageUrl;
  final double price;
  final int quantity;
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
    Timestamp? createdAt,
    Timestamp? updateAt,
  }) : createdAt = createdAt ?? Timestamp.now(),
       updateAt = updateAt ?? Timestamp.now();
}
