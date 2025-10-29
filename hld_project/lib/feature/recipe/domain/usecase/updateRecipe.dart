import '../entity/recipe.dart';
import '../repository/recipe_repository.dart';

class UpdateRecipeUseCase {
  final RecipeRepository repository;
  UpdateRecipeUseCase(this.repository);

  Future<void> call(Recipe recipe) {
    return repository.updateRecipe(recipe);
  }
}