# Super Kid Adventure

**Play. Learn. Explore. Become a Super Kid!**

An offline-first adventure game for kids ~6–9 years old (Class 2 / age 7
focus), built with Flutter + Flame. Learning (math, memory, patterns,
words) is woven into story-driven quests rather than presented as a quiz.

Full design brief: see `docs/GAME_DESIGN_BRIEF.md`.

## Status: Phase 11 of 13 — Save system + offline persistence

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

**Phase 8** —
- 5 companions (Robot, Fox, Panda, Monkey, Puppy — brief section 10),
  each paired one-to-one with a mini-game. A companion unlocks by
  earning a star in its paired mini-game — proof the child can already
  do it without help — and unlocking is recomputed live from real
  mini-game progress, never stored, same shape as Phase 7's badges
- `CompanionRepository` stores only the single equipped choice; at most
  one companion is active at a time, free to switch
- Each companion gives real, gameplay-affecting help once equipped —
  no cosmetic-only "helpers":
  - Robot / Fox: crosses out one wrong answer (once per question) in
    Math Dash / Pattern Power
  - Panda: 1.5x study time in Memory Master
  - Monkey: points at one real hidden target in every Find & Discover
    scene (the child still has to tap it)
  - Puppy: places Word Builder's first letter automatically
- "My Companions" screen (Home → My Companions): a badge-style grid,
  locked companions greyed with the mini-game that unlocks them,
  unlocked ones tappable to equip; the active companion also shows as
  a small badge on the Home hero avatar
- No coins were spent here — companions unlock through mini-game
  mastery, not purchase; the coin-spending shop is still Phase 9's
- Tests: catalog unlock-condition correctness (including "every
  companion" and "only its own mini-game"), repository persistence,
  My Companions screen's locked/unlocked/equip behavior, and each
  companion's actual in-game effect (hint elimination never touches
  the correct answer, Panda's exact 1.5x timing, Monkey's hint always
  points at a real target, Puppy's placed letter always matches)

**Phase 9** —
- `ShopCatalog`: 16 coin-priced items across 8 slots — the 4 existing
  hero categories (2 extra colors each, extending the free starter
  swatches rather than replacing them) plus 4 brand-new Player Room
  decoration slots (wall art, rug, plant, lamp)
- `CoinRepository` gained `spendCoins()` — the first place coins are
  actually spent; it refuses (and changes nothing) if the balance is
  short, so a purchase can never leave a negative balance
- `ShopRepository` / `RoomRepository`: what's been bought (a plain
  owned-ids set, same shape as Phase 8's companion unlocks) and what's
  equipped in each room slot (nullable per slot — a room starts
  genuinely empty, unlike the hero's always-has-a-default categories)
- **Shop screen**: every item, grouped by slot, with a Buy button that
  only ever enables when it's both unowned and affordable — no
  loot boxes, no randomness, every purchase is a specific named item
  at a fixed price
- **My Room screen**: 4 tappable slots around the hero; each opens a
  picker of just the items owned for that slot (plus "None") to equip
  — nothing sells directly from here, only from the Shop
- Hero Selection now shows any purchased hair/outfit/shoes/backpack
  color as an extra swatch alongside the free starter ones, and
  actually renders in that color once equipped (fixed a real bug along
  the way: the avatar preview used to only look up colors in the free
  catalog, so an equipped shop color would have silently rendered as
  whichever free color came first)
- Home gained a **My Room** entry point; its layout is now scrollable
  so it keeps working as more entry points get added in later phases
  instead of silently overflowing off small screens
- Tests: catalog correctness (unique ids, every category covered,
  hero/room partition), `spendCoins`' insufficient-funds and
  exact-balance edge cases, Shop's afford/owned button states and that
  buying actually spends+records, Room's empty/equip/clear slot flow
  and its Shop hand-off, Hero Selection's shop-swatch appearance and
  save, and a regression test for the avatar-color bug above

**Phase 10** —
- `PlayTimeTracker`: records real foreground play time off actual
  app-lifecycle resume/pause transitions (no periodic timer, so
  nothing is left running if the app — or a test — tears the widget
  tree down mid-session), persisted through the new
  `PlayTimeRepository`
- A "For grown-ups" gate (small, muted shield icon on Home, not a big
  colorful button a child would be drawn to tap) — a two-digit ×
  one-digit multiplication problem well beyond Class 2 mental math; a
  wrong attempt swaps in a fresh problem instead of letting it be
  brute-forced
- **Parent Zone dashboard**: play time, quests completed, a level bar
  per subject (reusing the same `DifficultyTracker` the mini-games
  already write to), and a recommended-practice suggestion — the
  subject with the lowest level, ties broken deterministically. Every
  number is read live from the repositories the game itself writes to;
  there's no separate reporting copy that could drift
- No purchase flow exists yet to gate (Phase 9's shop only spends
  coins, never real money), so the brief's "future purchases live
  behind this gate" is a placement note for later, not something built
  now
- Tests: gate-challenge generator correctness (operand ranges,
  determinism), play-time repository persistence, the tracker's
  resume/pause/dispose accounting (including that backgrounded time
  never counts and a second pause without a resume can't double-count),
  the duration formatter's rounding, the gate's wrong-answer/
  fresh-challenge/correct-answer flow, and the dashboard's stat and
  recommendation display against seeded progress

**Phase 11** —
- The game has been offline-first and locally persisted since Phase 1
  — every repository writes straight through `LocalStorageService`, no
  network calls exist anywhere. This phase makes that save system
  actually *visible and controllable* rather than adding new plumbing:
- Welcome now recognizes a returning player (`HeroRepository.
  hasSavedProfile`, distinct from `load()`'s always-usable default) and
  shows **Continue Adventure** straight to Home, instead of making
  them re-click through Hero Selection every single launch. A
  first-time player still sees **PLAY** exactly as before
- Parent Zone gained **Reset All Progress** (confirmation dialog, only
  reachable behind the existing parent gate): clears every key via a
  new `LocalStorageService.clearAll()` rather than a hand-maintained
  list of keys that would silently drift out of sync as later phases
  add more repositories, then returns to Welcome with the navigation
  stack cleared
- Audited every repository that stores JSON (hero, mini-game stars,
  quests, room, shop, difficulty tracker): all six already catch
  malformed data and fall back to sane defaults, confirmed consistent
  rather than assumed
- **Known, intentional scope boundary:** an in-progress mini-game
  round or quest (e.g. closing the app mid-Math-Dash) is not resumed
  exactly where it left off — only *completed* results are saved, same
  as before this phase. Rebuilding full mid-session state serialization
  wasn't asked for by the brief (Parent Zone wants completed quests
  and play time, not round-by-round replay) and would be a much larger
  change to make and verify without a compiler here
- Tests: `hasSavedProfile`'s true save-vs-default distinction, both
  Welcome branches and where each one navigates, and the Reset flow's
  cancel-does-nothing / confirm-clears-everything-and-returns-to-
  Welcome behavior

Not built yet: polish (Phase 12) and the Android release build
(Phase 13).

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
17. On Home, tap **My Companions**: 5 companions, all locked at first.
    Earn a star in any mini-game and return here — that companion is
    now shown in color and tappable; tap it to equip.
18. With Robot equipped, play Math Dash: a "Robot Hint" button appears
    each question and crosses out one wrong answer (never the right
    one) when tapped, once per question. Fox does the same in Pattern
    Power.
19. With Panda equipped, Memory Master's study phase visibly lasts
    longer and says so ("Panda is giving you extra time!").
20. With Monkey equipped, every Find & Discover scene has one item
    outlined — a real target, though you still have to tap it yourself.
21. With Puppy equipped, Word Builder always starts with the first
    letter already placed ("Puppy sniffed out the first letter!").
22. Only one companion can be equipped at a time; the active one also
    shows as a small badge on the Home hero avatar.
23. On Home, tap **My Room**: 4 empty decoration slots around your
    hero. Tap **Visit Shop**: every item grouped under Hero/Room, each
    with a price; a Buy button only lights up once you can actually
    afford it, and switches to "Owned" (disabled) right after buying.
24. Back in My Room, tap a slot you bought something for — a picker
    lists just what you own for that spot, plus "None". Equip one and
    it shows in the room; pick None and the slot goes back to "tap to
    add".
25. In My Room, tap your hero ("Tap to customize") to reopen Build
    Your Hero: any hair/outfit/shoes/backpack color you bought shows
    up as an extra swatch alongside the free ones, and the avatar
    actually renders in that color once picked and saved.
26. On Home, tap the small grey shield icon (top-left, deliberately not
    a big colorful button): a "For Grown-Ups" screen asks a
    multiplication question. Enter the wrong answer — a gentle "Not
    quite" message appears and the question changes to a new one (it
    can't be brute-forced by retrying the same number).
27. Enter the right answer: **Parent Zone** opens, showing play time,
    quests completed, a level bar for each subject, and a recommended
    subject to practice next.
28. Play for a bit, then background/reopen the app (or just close and
    reopen it) — play time in Parent Zone increases to reflect real
    time spent in the app.
29. Fully close and reopen the app: Welcome now shows **Continue
    Adventure** instead of **PLAY**, and tapping it goes straight to
    Home — no more rebuilding your hero every launch.
30. In Parent Zone, scroll down and tap **Reset All Progress**: a
    confirmation dialog appears. Tap **Cancel** — nothing changes.
    Open it again and tap **Reset** — you're dropped back at Welcome,
    which now shows **PLAY** again (a completely fresh save).
31. `flutter test` passes (all widget + unit tests).
32. `flutter analyze` reports no errors.

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
    tracking/                # PlayTimeTracker (app-lifecycle play time)
    utils/                   # DurationFormatter
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
    companions/                 # "My Companions" selection screen
    room/                    # "My Room" decoration screen
    shop/                    # coin shop screen
    parent_zone/             # parent gate + Parent Zone dashboard
  game/
    models/                 # HeroProfile, WorldLocation, Quest, WordPuzzle, FindScene, GameBadge, Companion, ShopItem, RoomProfile, ParentGateChallenge, ...
    data/                    # HeroCustomizationCatalog, WordBank, BadgeCatalog, CompanionCatalog, ShopCatalog
    repositories/            # HeroRepository, ProgressRepository, CoinRepository,
                              # QuestRepository, MiniGameRepository, CompanionRepository,
                              # ShopRepository, RoomRepository, PlayTimeRepository
    worlds/                  # JungleWorld (Space/Dino/Magic/Robot: later)
    systems/                 # QuestEngine, DifficultyTracker, all 5 puzzle generators,
                              # ParentGateChallengeGenerator
    quests/                  # JungleQuests content (10 quests, data only)
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
