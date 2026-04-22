import '../../../core/api/api_client.dart';
import '../domain/recipe.dart';

class RecipesResponse {
  const RecipesResponse({required this.mode, required this.recipes});

  final String mode;
  final List<Recipe> recipes;
}

class RecipesRepository {
  RecipesRepository({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  Future<RecipesResponse> generate({
    required List<String> ingredients,
    int count = 5,
  }) async {
    final body = await _api.postJson('/api/recipes/generate', {
      'ingredients': ingredients,
      'count': count,
    });
    final raw = (body['recipes'] as List?) ?? const [];
    return RecipesResponse(
      mode: (body['mode'] as String?) ?? 'unknown',
      recipes: raw
          .whereType<Map<String, dynamic>>()
          .map(Recipe.fromJson)
          .toList(),
    );
  }
}
