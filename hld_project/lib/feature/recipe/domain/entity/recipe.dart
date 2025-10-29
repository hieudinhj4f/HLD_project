import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String? id;
  final String name;
  final String category;
  final int time;
  final String imageUrl;
  final String videoUrl;
  final String ingredients;
  final String steps;

  const Recipe({
    this.id,
    required this.name,
    required this.category,
    required this.time,
    required this.imageUrl,
    required this.videoUrl,
    required this.ingredients,
    required this.steps,
  });

}