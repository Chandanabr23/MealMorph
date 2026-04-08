import 'package:flutter/material.dart';

import 'fridge_thumbnail_io.dart' if (dart.library.html) 'fridge_thumbnail_web.dart'
    as thumb;

/// Local file image from camera; web uses a neutral placeholder (no [dart:io]).
class FridgeThumbnail extends StatelessWidget {
  const FridgeThumbnail({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) => thumb.buildThumbnail(path);
}
