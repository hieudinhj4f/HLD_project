import '../entity/recipe.dart';

abstract class RecipeRepository {
  /// Lấy danh sách món ăn, hỗ trợ lọc, tìm kiếm và sắp xếp
  Future<List<Recipe>> getRecipes({String? category, String? searchQuery});

  /// Lấy TẤT CẢ món ăn (đã thêm)
  Future<List<Recipe>> getAllRecipes();

  /// Lấy một món ăn theo ID (đã thêm)
  Future<Recipe?> getRecipeById(String id);

  /// Thêm món ăn mới
  Future<void> createRecipe(Recipe recipe);

  /// Cập nhật món ăn
  Future<void> updateRecipe(Recipe recipe);

  /// Xóa món ăn
  Future<void> deleteRecipe(String id);
}