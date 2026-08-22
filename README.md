# Super Kid Adventure

**Play. Learn. Explore. Become a Super Kid!**

An offline-first adventure game for kids ~6–9 years old (Class 2 / age 7
focus), built with Flutter + Flame. Learning (math, memory, patterns,
words) is woven into story-driven quests rather than presented as a quiz.

Full design brief: see `docs/GAME_DESIGN_BRIEF.md`.

## Status: Phase 7 of 13 — Rewards system (stars, coins, badges)

This repo is being built in phases (see `docs/GAME_DESIGN_BRIEF.md`
section 23 / `docs/PHASE_PLAN.md`). Implemented so far:

**Phase 1** — Flutter project scaffold (Dart source only — see
**First-time setup** below for why platform folders aren't committed
yet), folder architecture, bright rounded large-touch-target theme,
named-route navigation, `LocalStorageService` abstraction over
`shared_preferences`.

**Phase 2** — Hero customization (4 swatch categories, live "paper
doll" preview, no personal info, saved locally), Home screen, and the
Jungle Adventure map with star-gated locked/unlocked locations.

**Phase 3** —
- Quest data model (`Quest` + `ChoiceChallenge`) and a fully
  unit-tested `QuestEngine`: challenge progression, gentle rotating
  encouragement on wrong answers (never "Wrong!"), one-time star
  rewards, replays allowed for practice
- 10 complete story-driven Jungle quests (2 per location, 3 challenges
  each) as pure content files — math within 20, patterns, sequences and
  picture words for Class 2 / age ~7
- Quest flow screens: location quest list → story intro → play (big
  visuals, progress dots, story-item reward dialogs) → animated
  celebration with stars
- Stars now genuinely accumulate and unlock map locations; content
  tests prove every location is reachable with the stars earnable
  before it
- Challenges are the Phase 3 tap-an-answer type; the richer Math
  Dash / Memory Master / Word Builder mini-games (Phases 4–6) plug into
  this same quest flow

**Phase 4** —
- `DifficultyTracker` (brief section 13): per-subject levels 1–5,
  persisted; 3 first-try corrects in a row level up, 2 misses in a row
  gently level down — the child never sees a message about it, the
  questions just fit better
- `MathQuestionGenerator`: unlimited addition / subtraction /
  comparison / sequence questions scaled to the tracker's level, with
  countable emoji visuals for small quantities; reuses the quest
  `ChoiceChallenge` model so generated questions can plug into quests
  later
- Mini-Games hub on Home (lists only games that exist) and the Math
  Dash screen: 8-question rounds, first-try score, gentle retry on
  misses, predictable reward stated up front (6+ right = +1 ⭐)
- Tests: tracker leveling/persistence, generator correctness (sums,
  no negative subtraction, bigger-number comparison, sequence
  continuation), and deterministic widget tests for perfect rounds,
  missed rounds and replay

**Phase 5** —
- `MemoryRoundGenerator`: show-then-hide rounds covering all 4 memory
  question types from brief section 9B — position, sequence ("what
  came right after X?"), object ("which did you NOT see?"), and count —
  item count and study time scale with the shared `DifficultyTracker`
- `PatternQuestionGenerator`: repeating-unit patterns (unit length 2–3,
  e.g. ⭐🔵⭐🔵❓ or 🦁🐾🐾🦁🐾🐾❓) also scaled by level
- Memory Master screen: study phase (items shown, then hidden) → answer
  → same gentle-retry/reward shape as Math Dash (5 rounds, 4+ first-try
  = +1 ⭐)
- Pattern Power screen: same round shape as Math Dash (8 rounds, 6+ =
  +1 ⭐), reusing `ChallengeCategory.logic`'s difficulty tracking
- Mini-Games hub now lists all three games
- Tests: both generators' correctness (position/sequence/object/count
  answers actually match what was shown; pattern answers continue the
  real repeating unit), and deterministic widget tests including one
  that explicitly waits out a round's study timer before answering

**Phase 6** —
- `WordBank` + `WordPuzzleGenerator`: curated emoji↔word pairs (3/4/5
  letters by level, no ambiguous emoji-to-word pairings), plus letter
  scrambling
- Word Builder screen: tap scrambled letter tiles into order to spell
  the pictured word; tapping a placed tile returns it (always
  fixable); 6 rounds, 4+ first-try = +1 ⭐
- `FindSceneGenerator`: scatters a target object among decoys into one
  shuffled scene
- Find & Discover screen: tap every copy of the target; wrong taps
  don't block progress, they just cost that scene's "clean" bonus; 4
  scenes (busier each round), 3+ clean = +1 ⭐
- Mini-Games hub now lists all five built games
- Tests: word-length/emoji sanity + scramble correctness, scene
  target/decoy correctness, and deterministic widget tests for both
  screens (perfect play, retry-after-mistake, double-tap no-ops)

**Known gap, not silently absorbed into any phase:** the design
brief's Quick Challenge mini-game type (section 21's "10 Quick
Challenges" minimum) has no phase of its own in `docs/PHASE_PLAN.md`'s
13-phase list — it needs to be explicitly scheduled.

**Phase 7** —
- `CoinRepository`: a second currency alongside stars (brief section
  11) — stars still gate map progression, coins are the future shop
  currency for Phase 9's cosmetics
- Quests now award coins too, derived from `starReward` (no edits to
  the already-verified quest content needed); each mini-game awards a
  flat coin bonus alongside its star
- `MiniGameRepository`: tracks which mini-games have had a star earned
  at least once — the only new fact needed for mini-game badges
- `BadgeCatalog`: 10 badges (1 per mini-game, first-quest, complete-
  all-Jungle-quests, 20-star and 20-coin collectors, and a "Super Kid"
  capstone for earning every other badge). Earned status is **never
  stored** — it's recomputed live from real quest/mini-game/star/coin
  data every time, so a badge can't say "earned" for something that
  didn't happen
- Collection screen (brief's "🎒 Collection"): a badge grid, earned
  ones bright with their description, locked ones greyed with a lock
- Home now shows both currencies and a "My Collection" entry point
- Tests: coin/mini-game repository correctness, badge-condition
  correctness for every badge type (including the capstone's
  earn-everything-else condition), and widget tests verifying the
  Collection screen's earned/locked split actually matches seeded
  progress

Not built yet: companions, player room, Parent Zone, coin-spending UI
(coins accumulate now; Phase 9 builds what they buy). Those land in
Phases 8–13.

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
4. Tapping **Start Adventure** goes to **Home**: your hero, a star
   count, and an **Adventure Map** button.
5. On the **Adventure Map**, tap **Tree House** → a list of 2 quests.
   Locked locations still show a gentle "Earn N more ⭐" hint.
6. Play **Repair the Jungle Bridge**: story intro → 3 challenges with
   big emoji visuals and tap-to-answer buttons. A wrong answer shows
   encouragement ("Almost! Let's try again!") and lets you retry; each
   solved challenge awards a story item (Bridge Piece 1…3); finishing
   shows a celebration screen with **+2 ⭐**.
7. Back on the map, your stars now count toward unlocks: after both
   Tree House quests (4 ⭐), **Monkey Camp** (3 ⭐) unlocks. Completing
   all 10 quests (20 ⭐) opens every location including the Temple.
8. Replay a completed quest: it's marked "Completed! Play again for
   practice" and awards no extra stars.
9. From **Home**, tap **Mini-Games** → **Math Dash**: the intro states
   the reward rule ("Get 6 right on the first try to earn a ⭐"), then
   8 puzzles — small counts appear as countable emoji. Answer 3 in a
   row correctly across rounds and the questions quietly get harder;
   struggle and they ease off.
10. Back at Mini-Games, try **Memory Master**: watch the emoji shown,
    they disappear, then answer a question about them (position/order/
    what you saw/how many). 4 of 5 first-try correct earns a ⭐.
11. Try **Pattern Power**: a repeating emoji pattern with a "❓" at the
    end — tap what comes next. 6 of 8 first-try correct earns a ⭐.
12. Try **Word Builder**: an emoji (e.g. 🐶) with scrambled letter
    tiles below — tap them in order to spell the word; tap a placed
    letter to undo it. 4 of 6 first-try correct earns a ⭐.
13. Try **Find & Discover**: a grid scattered with a target object
    (e.g. "Find 2 bananas!") among decoys — tap every copy; a wrong
    tap flashes red but doesn't stop you. 3 of 4 clean scenes earns a ⭐.
14. Notice both a ⭐ and 🪙 count now show on Home, and every quest /
    mini-game reward screen shows coins earned alongside stars.
15. On Home, tap **My Collection**: a grid of badges, all locked at
    first. Earn a star in any mini-game (or complete a quest) and
    return here — that badge is now bright with its description, and
    the "N of 10 badges earned" count at the top updates.
16. Close and reopen the app: hero, stars, coins, completed quests,
    mini-game stars, and difficulty levels all persist.
17. `flutter test` passes (all widget + unit tests).
18. `flutter analyze` reports no errors.

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
    quests/                  # quest list / intro / play / celebration
    mini_games/              # hub + all 5 mini-games
    collection/               # badge grid screen
    room/                    # (Phase 9)
    parent_zone/             # (Phase 10)
  game/
    models/                 # HeroProfile, WorldLocation, Quest, WordPuzzle, FindScene, GameBadge, ...
    data/                    # HeroCustomizationCatalog, WordBank, BadgeCatalog
    repositories/            # HeroRepository, ProgressRepository, CoinRepository,
                              # QuestRepository, MiniGameRepository
    worlds/                  # JungleWorld (Space/Dino/Magic/Robot: later)
    systems/                 # QuestEngine, DifficultyTracker, all 5 puzzle generators
    quests/                  # JungleQuests content (10 quests, data only)
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
