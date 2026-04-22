import 'package:flutter/foundation.dart';

import '../domain/fridge_item.dart';

/// In-memory fridge store, shared across screens via a singleton.
///
/// Listeners (e.g. `MyFridgeScreen`, `RecipesScreen`) subscribe to
/// [items] and are notified on every mutation.
class FridgeRepository {
  FridgeRepository._();

  static final FridgeRepository instance = FridgeRepository._();

  final ValueNotifier<List<FridgeItem>> items = ValueNotifier<List<FridgeItem>>(
    const [],
  );

  void add(FridgeItem item) {
    items.value = [...items.value, item];
  }

  void addAll(Iterable<FridgeItem> newItems) {
    items.value = [...items.value, ...newItems];
  }

  void replace(String id, FridgeItem next) {
    items.value = [
      for (final it in items.value)
        if (it.id == id) next else it,
    ];
  }

  void remove(String id) {
    items.value = items.value.where((it) => it.id != id).toList(growable: false);
  }

  void clear() {
    items.value = const [];
  }

  int get stored => items.value.length;
  int get expiring => items.value.where((e) => e.expiringSoon).length;
}
