import 'package:flutter/material.dart';

/// Root [ScaffoldMessenger] so sign-in feedback survives popping the login route stack.
final GlobalKey<ScaffoldMessengerState> mealMorphMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
