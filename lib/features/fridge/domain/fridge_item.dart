/// One fridge entry. May come from a camera capture, receipt scan, or manual
/// entry — `imagePath` is null for entries without a captured image.
class FridgeItem {
  const FridgeItem({
    required this.id,
    this.imagePath,
    this.name,
    this.detail,
    this.expiringSoon = false,
    this.category,
    this.quantity,
    this.unit,
    this.expiresOn,
  });

  final String id;
  final String? imagePath;
  final String? name;
  final String? detail;
  final bool expiringSoon;
  final String? category;
  final double? quantity;
  final String? unit;
  final DateTime? expiresOn;

  FridgeItem copyWith({
    String? name,
    String? detail,
    bool? expiringSoon,
    String? category,
    double? quantity,
    String? unit,
    DateTime? expiresOn,
  }) {
    return FridgeItem(
      id: id,
      imagePath: imagePath,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      expiringSoon: expiringSoon ?? this.expiringSoon,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiresOn: expiresOn ?? this.expiresOn,
    );
  }

  /// Strings usable as AI prompt input.
  String toIngredientString() {
    final base = (name?.trim().isNotEmpty ?? false) ? name!.trim() : 'ingredient';
    final qty = quantity != null && unit != null ? ' ($quantity $unit)' : '';
    return expiringSoon ? '$base$qty [expiring soon]' : '$base$qty';
  }
}
