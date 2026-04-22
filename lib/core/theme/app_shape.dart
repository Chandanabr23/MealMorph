import 'package:flutter/material.dart';

/// Corner-radius scale.
///
/// `full` = pill / stadium shape; resolve via [StadiumBorder] directly.
abstract final class AppRadius {
  static const Radius sm = Radius.circular(12);
  static const Radius md = Radius.circular(24);
  static const Radius lg = Radius.circular(32);
  static const Radius xl = Radius.circular(48);
}

abstract final class AppShape {
  static const BorderRadius allMd = BorderRadius.all(AppRadius.md);
  static const BorderRadius allLg = BorderRadius.all(AppRadius.lg);

  /// Signature "leaf" radius: rounded on top-left + bottom-right only.
  static const BorderRadius leaf = BorderRadius.only(
    topLeft: AppRadius.xl,
    bottomRight: AppRadius.xl,
  );
}
