import '../../../core/api/api_client.dart';

class IngredientCategory {
  const IngredientCategory({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final String icon;

  factory IngredientCategory.fromJson(Map<String, dynamic> json) {
    return IngredientCategory(
      id: (json['id'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      icon: (json['icon'] as String?) ?? 'leaf',
    );
  }
}

class CommonIngredient {
  const CommonIngredient({
    required this.id,
    required this.name,
    required this.category,
    required this.shelfLifeDays,
  });

  final String id;
  final String name;
  final String category;
  final int shelfLifeDays;

  factory CommonIngredient.fromJson(Map<String, dynamic> json) {
    return CommonIngredient(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      shelfLifeDays: (json['shelfLifeDays'] as num?)?.toInt() ?? 0,
    );
  }
}

class CatalogRepository {
  CatalogRepository({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  Future<List<IngredientCategory>> categories() async {
    final body = await _api.getJson('/api/catalog/categories');
    final raw = (body['categories'] as List?) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(IngredientCategory.fromJson)
        .toList();
  }

  Future<List<CommonIngredient>> commonlyAdded() async {
    final body = await _api.getJson('/api/catalog/commonly-added');
    final raw = (body['items'] as List?) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CommonIngredient.fromJson)
        .toList();
  }
}
