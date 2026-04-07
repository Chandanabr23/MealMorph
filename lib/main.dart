import 'package:flutter/material.dart';

import 'app/mealmorph_app.dart';
import 'core/strings/app_strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final strings = await AppStrings.load();
  runApp(MealMorphApp(strings: strings));
}
