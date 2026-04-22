class DetectedIngredient {
  const DetectedIngredient({
    required this.name,
    required this.category,
    required this.quantity,
    required this.confidence,
  });

  final String name;
  final String category;
  final String? quantity;
  final double confidence;

  factory DetectedIngredient.fromJson(Map<String, dynamic> json) {
    final rawQty = json['quantity'];
    return DetectedIngredient(
      name: (json['name'] as String?)?.trim() ?? '',
      category: (json['category'] as String?) ?? 'other',
      quantity: rawQty is String ? rawQty : null,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ScanResponse {
  const ScanResponse({required this.mode, required this.items});

  final String mode;
  final List<DetectedIngredient> items;
}
