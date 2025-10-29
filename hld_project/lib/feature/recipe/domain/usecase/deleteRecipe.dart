import '../entity/recipe.dart';
import '../repository/recipe_repository.dart';
class DeleteRecipeUseCase {
  final RecipeRepository repository;
  DeleteRecipeUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteRecipe(id);
  }
}