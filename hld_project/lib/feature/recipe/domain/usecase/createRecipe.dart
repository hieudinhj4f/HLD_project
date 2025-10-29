import '../entity/recipe.dart';
import '../repository/recipe_repository.dart';

class CreateRecipeUseCase {
  final RecipeRepository repository;
  CreateRecipeUseCase(this.repository);

  Future<void> call(Recipe recipe) {
    return repository.createRecipe(recipe);
  }
}