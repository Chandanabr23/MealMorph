import 'package:flutter/material.dart';

import 'app_strings.dart';

class AppStringsScope extends InheritedWidget {
  const AppStringsScope({
    super.key,
    required this.strings,
    required super.child,
  });

  final AppStrings strings;

  static AppStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStringsScope>();
    assert(scope != null, 'AppStringsScope not found above this context');
    return scope!.strings;
  }

  @override
  bool updateShouldNotify(covariant AppStringsScope oldWidget) =>
      strings != oldWidget.strings;
}
