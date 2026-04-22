enum RecipeDifficulty { beginner, intermediate, pro, unknown }

RecipeDifficulty _parseDifficulty(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'beginner':
      return RecipeDifficulty.beginner;
    case 'intermediate':
      return RecipeDifficulty.intermediate;
    case 'pro':
    case 'advanced':
    case 'expert':
      return RecipeDifficulty.pro;
    default:
      return RecipeDifficulty.unknown;
  }
}

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.tagline,
    required this.difficulty,
    required this.minutes,
    required this.usesIngredients,
    required this.coverage,
    required this.featured,
    required this.heroImageQuery,
  });

  final String id;
  final String title;
  final String tagline;
  final RecipeDifficulty difficulty;
  final int minutes;
  final List<String> usesIngredients;
  final double coverage;
  final bool featured;
  final String heroImageQuery;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Untitled',
      tagline: (json['tagline'] as String?) ?? '',
      difficulty: _parseDifficulty(json['difficulty'] as String?),
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      usesIngredients: ((json['usesIngredients'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      coverage: (json['coverage'] as num?)?.toDouble() ?? 0.0,
      featured: (json['featured'] as bool?) ?? false,
      heroImageQuery: (json['heroImageQuery'] as String?) ?? '',
    );
  }
}

String recipeImageUrl(Recipe r) {
  final q = Uri.encodeComponent(r.heroImageQuery.isNotEmpty ? r.heroImageQuery : r.title);
  return 'https://source.unsplash.com/featured/800x600/?$q,food';
}
