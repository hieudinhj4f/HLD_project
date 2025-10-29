// Imports của Domain
import '../../domain/entity/recipe.dart';
import '../../domain/repository/recipe_repository.dart';

// Imports của Data
import '../datasource/recipe_repository_datasource.dart';
import '../model/recipe_model.dart';

/// Implementation of RecipeRepository (Data Layer)
/// Đã triển khai đầy đủ 6 phương thức
class RecipeRepositoryImpl implements RecipeRepository {
  // Dependency Injection của Data Source
  final RecipeRemoteDataSource _remoteDataSource;

  RecipeRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createRecipe(Recipe recipe) async {
    // 1. Ánh xạ Entity (Domain) sang Model (Data)
    final model = RecipeModel.fromEntity(recipe);
    // 2. Gọi Data Source để thực hiện I/O
    await _remoteDataSource.add(model);
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    final model = RecipeModel.fromEntity(recipe);
    await _remoteDataSource.update(model);
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await _remoteDataSource.delete(id);
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    // Gọi hàm getRecipe từ datasource
    final model = await _remoteDataSource.getRecipe(id);

    // Ánh xạ Model (Data) sang Entity (Domain)
    // Lỗi của bạn nằm ở đây, hãy chắc chắn 'model' import đúng 'Recipe'
    return model?.toEntity();
  }

  @override
  Future<List<Recipe>> getAllRecipes() async { // <-- Thêm 'async'
    final models = await _remoteDataSource.getAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Recipe>> getRecipes({String? category, String? searchQuery}) async {
    // 1. Gọi DataSource với các tham số lọc
    final List<RecipeModel> models = await _remoteDataSource.getRecipes(
      category: category,
      searchQuery: searchQuery,
    );

    // 2. Ánh xạ List<Model> (Data) sang List<Entity> (Domain)
    return models.map((model) => model.toEntity()).toList();
  }
}