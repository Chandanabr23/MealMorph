# MealMorph

Flutter app that helps reduce food waste by turning what you have in the fridge into cookable recipes—with an editorial onboarding flow and strings driven by a single JSON file.

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
