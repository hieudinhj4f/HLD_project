import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/recipe.dart'; // Import lớp cha Recipe

class RecipeModel extends Recipe {
  RecipeModel({
    required super.id,
    required super.name,
    required super.category,
    required super.time,
    required super.imageUrl,
    required super.videoUrl,
    required super.ingredients,
    required super.steps,
  });

  /// 🔹 Factory: chuyển dữ liệu Firestore → RecipeModel
  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RecipeModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      time: data['time'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      ingredients: data['ingredients'] ?? '',
      steps: data['steps'] ?? '',
    );
  }

  /// 🔹 Model → Entity (Domain)
  // (Lưu ý: Vì Model extends Entity, hàm này chỉ đơn giản là trả về chính nó
  // dưới kiểu cha, nhưng tôi giữ lại để đúng với cấu trúc bạn đưa)
  Recipe toEntity() {
    return Recipe(
      id: id,
      name: name,
      category: category,
      time: time,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      ingredients: ingredients,
      steps: steps,
    );
  }

  /// 🔹 Entity (Domain) → Model (Data)
  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      name: recipe.name,
      category: recipe.category,
      time: recipe.time,
      imageUrl: recipe.imageUrl,
      videoUrl: recipe.videoUrl,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
    );
  }

  /// 🔹 Model → JSON (Map) để ghi lên Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'time': time,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'ingredients': ingredients,
      'steps': steps,
      // Bạn có thể thêm 'createdAt', 'updatedAt' nếu cần
    };
  }
}