# MealMorph

MealMorph is a Flutter app that transforms ingredients from your fridge, captured through photos or extracted from grocery receipts, into expiry-aware recipes so food is used before it goes to waste. It uses a Node.js backend with OpenAI GPT-4o-mini to identify ingredients and generate recipes that prioritise items closest to spoiling, while Firebase Authentication enables secure sign-in and a shared digital pantry across Home, Recipes, Scan, and Profile. The experience is shaped by a Digital Greenhouse design system featuring refined typography, organic forms, and layered glass-like surfaces, giving the app the feel of a premium culinary magazine rather than a typical utility.

<img width="1343" height="678" alt="image" src="https://github.com/user-attachments/assets/f5dc9a85-d3f6-4c56-a441-66499baaef25" />







## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) (see `pubspec.yaml` for SDK constraint)

## Run the app

```bash
flutter pub get
flutter run
```

Pick a device or emulator when prompted, or use `-d chrome` for web.

## Project structure

The codebase follows a **feature-first** layout with shared **core** and an **app** entry:

| Path | Role |
|------|------|
| `lib/main.dart` | Async bootstrap: loads strings, then `runApp` |
| `lib/app/mealmorph_app.dart` | `MaterialApp`, theme, `AppStringsScope` |
| `lib/core/theme/` | Colors and `ThemeData` |
| `lib/core/strings/` | `text.json` loader + `InheritedWidget` scope |
| `lib/features/<feature>/presentation/` | Screens and UI for that feature |

## Editing copy (no code changes)

All user-visible strings for the current onboarding screen (plus app title and hero image URL) live in:

**`assets/strings/text.json`**

After you change this file, do a **full restart** (not only hot reload), because strings are read once at startup in `main()`.

## Tests

```bash
flutter test
```

## License

Private project (`publish_to: 'none'` in `pubspec.yaml`).
