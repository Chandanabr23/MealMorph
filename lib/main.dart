import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/mealmorph_app.dart';
import 'bootstrap/init_firebase.dart';
import 'core/strings/app_strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ensureFirebaseInitialized();
  // ignore: avoid_print
  print(Firebase.app().options.projectId);

  final strings = await AppStrings.load();
  runApp(MealMorphApp(strings: strings));
}
