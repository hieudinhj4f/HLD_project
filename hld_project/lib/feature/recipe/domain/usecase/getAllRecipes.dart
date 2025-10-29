import '../entity/recipe.dart';
import '../repository/recipe_repository.dart';

class GetAllRecipesUseCase {
  final RecipeRepository repository;

  GetAllRecipesUseCase(this.repository);

  /// Hàm call() này không cần tham số
  Future<List<Recipe>> call()  => repository.getAllRecipes();
}