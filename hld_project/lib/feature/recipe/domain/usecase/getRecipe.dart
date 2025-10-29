import '../entity/recipe.dart';
import '../repository/recipe_repository.dart';

class GetRecipesUseCase {
  final RecipeRepository repository;

  GetRecipesUseCase(this.repository);

  /// Hàm call() này nhận tham số để lọc và tìm kiếm
  Future<List<Recipe>> call({String? category, String? searchQuery}) {
    return repository.getRecipes(
      category: category,
      searchQuery: searchQuery,
    );
  }
}