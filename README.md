# Super Kid Adventure

**Play. Learn. Explore. Become a Super Kid!**

An offline-first adventure game for kids ~6–9 years old (Class 2 / age 7
focus), built with Flutter + Flame. Learning (math, memory, patterns,
words) is woven into story-driven quests rather than presented as a quiz.

Full design brief: see `docs/GAME_DESIGN_BRIEF.md`.

## Status: Phase 2 of 13 — Hero + home + adventure map

This repo is being built in phases (see `docs/GAME_DESIGN_BRIEF.md`
section 23 / `docs/PHASE_PLAN.md`). Implemented so far:

**Phase 1** — Flutter project scaffold (Dart source only — see
**First-time setup** below for why platform folders aren't committed
yet), folder architecture, bright rounded large-touch-target theme,
named-route navigation, `LocalStorageService` abstraction over
`shared_preferences`.

**Phase 2** —
- Hero customization: 4 swatch categories (hair/outfit/shoes/backpack),
  live "paper doll" preview, no text entry or personal info
  (`HeroProfile`, `HeroRepository`, saved locally)
- Home screen: hero preview, star count, single "Adventure Map" action
- Jungle Adventure map: 5 real locations from the design brief, animated
  entrance, locked/unlocked state driven by `ProgressRepository`'s star
  count (real logic — just nothing awards stars yet, since that's the
  quest engine's job in Phase 3)
- Tapping an unlocked location opens an honest "quest arrives in Phase
  3" placeholder; tapping a locked one shows an encouraging hint instead
  of doing nothing
- Widget tests covering the full flow, plus unit tests for both new
  repositories and the unlock logic

Nothing beyond this has been built yet — no quests, no mini-games, no
companions, no rewards. Those land in Phases 3–13, one phase at a time,
each verified to compile before moving on.

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
3. Tapping **PLAY** opens **Build Your Hero**: tap swatches in each of
   the 4 rows (Hair/Outfit/Shoes/Backpack) and watch the avatar preview
   above update live.
4. Tapping **Start Adventure** goes to **Home**: your hero, a star count
   (0 — nothing awards stars yet), and an **Adventure Map** button.
5. Tapping **Adventure Map** shows 5 Jungle locations animating in.
   **Tree House** is unlocked and tappable (opens a "quest arrives in
   Phase 3" placeholder); the other 4 are locked with a star requirement
   shown, and tapping one shows a gentle "Earn N more ⭐" hint instead of
   doing nothing.
6. Close and reopen the app (or hot-restart): your hero customization is
   still there (Phase 11's full save system isn't built yet, but this
   piece of persistence already works).
7. `flutter test` passes (all widget + unit tests).
8. `flutter analyze` reports no errors.

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
    player/                 # hero selection + avatar preview widget
    home/
    adventure_map/
    room/                    # (Phase 9)
    parent_zone/             # (Phase 10)
  game/
    models/                 # HeroProfile, WorldLocation, CustomizationOption
    data/                    # HeroCustomizationCatalog
    repositories/            # HeroRepository, ProgressRepository
    worlds/                  # JungleWorld (Space/Dino/Magic/Robot: Phase 2+)
    systems/                 # (Phase 3+)
    quests/                  # (Phase 3)
    mini_games/               # (Phase 4-6)
    rewards/                   # (Phase 7)
    companions/                 # (Phase 8)
  shared/
    widgets/                 # BigRoundedButton, PlaceholderScreen, ...
test/
  game/                     # unit tests for repositories + models
  support/                  # FakeLocalStorageService
```

## Assets

No production art/audio is included yet. The hero avatar and map icons
are all drawn in code (colored shapes + Material icons), not
illustrations — see `lib/features/player/hero_avatar_preview.dart` and
`lib/game/worlds/jungle_world.dart`. No copyrighted third-party
characters are used anywhere in this project. A real asset manifest will
be added once professional art starts replacing these placeholders.
