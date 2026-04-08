import 'dart:io';

import 'package:flutter/material.dart';

Widget buildThumbnail(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return const ColoredBox(
      color: Color(0xFFEAE7E7),
      child: Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
  return Image.file(file, fit: BoxFit.cover);
}
