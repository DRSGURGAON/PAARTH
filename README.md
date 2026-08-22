# Super Kid Adventure

**Play. Learn. Explore. Become a Super Kid!**

An offline-first adventure game for kids ~6–9 years old (Class 2 / age 7
focus), built with Flutter + Flame. Learning (math, memory, patterns,
words) is woven into story-driven quests rather than presented as a quiz.

Full design brief: see `docs/GAME_DESIGN_BRIEF.md`.

## Status: Phase 1 of 13 — Project setup + architecture + theme + navigation

This repo is being built in phases (see `docs/GAME_DESIGN_BRIEF.md`
section 23 / `docs/PHASE_PLAN.md`). Only Phase 1 is implemented so far:

- Flutter project scaffold (Dart source only — see **First-time setup**
  below for why platform folders aren't committed yet)
- Folder architecture (`core/`, `features/`, `shared/`, `game/` reserved
  for Phase 3+)
- Theme (bright, rounded, large-touch-target, Material 3)
- Navigation (`onGenerateRoute` + named routes)
- Local storage abstraction (`LocalStorageService`, backed by
  `shared_preferences`), initialized on app start
- Screens: Splash (animated) → Welcome → Hero Selection (honest
  placeholder, arrives in Phase 2)
- A basic widget test proving the app boots and the Play button navigates

Nothing beyond this has been built yet — no hero, no map, no quests, no
mini-games. Those land in Phases 2–13, one phase at a time, each verified
to compile before moving on.

## First-time setup

This repo currently ships **only the Dart application source**
(`pubspec.yaml`, `lib/`, `test/`) — the `android/` and `ios/` platform
folders are intentionally *not* committed, because they contain
Gradle/Xcode scaffolding that must match your locally installed Flutter
SDK version exactly. `flutter create` is safe to re-run on an existing
project: it fills in missing platform folders without touching your
existing `pubspec.yaml` or `lib/` code.

```bash
git clone <this-repo-url>
cd super_kid_adventure

# Generates android/ (and ios/ if you pass it) matching your installed
# Flutter version. Safe to run — it will not overwrite pubspec.yaml,
# lib/, analysis_options.yaml or .gitignore, which already exist.
flutter create --platforms=android .

flutter pub get
flutter run
```

Requirements: Flutter stable channel, Android Studio or VS Code with the
Flutter plugin, an Android emulator or device (Android-first for V1;
iOS support is architected for but not built yet — see the brief).

## What to test right now

1. App launches to an animated splash screen showing "Super Kid
   Adventure", then auto-advances to the Welcome screen after ~2s.
2. Welcome screen shows the game title, tagline, and a big **PLAY**
   button.
3. Tapping **PLAY** navigates to a "Hero Selection — arriving in Phase 2"
   placeholder with a working **Back** button.
4. `flutter test` passes (2 widget tests).
5. `flutter analyze` reports no errors.

## Project structure

```
lib/
  main.dart              # entry point: init storage, runApp
  app.dart                # MaterialApp, theme + routing wiring
  core/
    constants/            # app-wide constants
    di/                    # AppScope — minimal service injection
    navigation/            # route names + route generator
    storage/               # LocalStorageService abstraction + impl
    theme/                 # colors + ThemeData
    audio/                 # (Phase 12)
  features/
    splash/
    welcome/
    adventure_map/         # (Phase 2)
    player/                 # (Phase 2/9)
    room/                    # (Phase 9)
    parent_zone/             # (Phase 10)
  game/
    models/                 # (Phase 3+)
    systems/
    quests/                  # (Phase 3)
    worlds/                   # (Phase 2/3)
    mini_games/               # (Phase 4-6)
    rewards/                   # (Phase 7)
    companions/                 # (Phase 8)
  shared/
    widgets/                 # BigRoundedButton, PlaceholderScreen, ...
test/
```

## Assets

No production art/audio is included yet — all placeholders are drawn in
code (icons, colored shapes). No copyrighted third-party characters are
used anywhere in this project. An asset manifest documenting what needs
professional artwork will be added once Phase 2 introduces the first
real visual content.
