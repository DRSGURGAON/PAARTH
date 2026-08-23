# Super Kid Adventure

**Play. Learn. Explore. Become a Super Kid!**

An offline-first adventure game for kids ~6–9 years old (Class 2 / age 7
focus), built with Flutter. Learning (math, memory, patterns,
words) is woven into story-driven quests rather than presented as a quiz.
(The brief scoped in Flame "where appropriate" — V1's screens turned out
to be straightforward Flutter UI throughout, so it was never pulled in;
see Phase 13's notes below.)

Full design brief: see `docs/GAME_DESIGN_BRIEF.md`. Building an Android
release from this repo: see `docs/RELEASE.md`.

## Status: Phase 13 of 13 — Testing + Android release build (V1 complete)

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

**Phase 12** —
- **Sound — an honest scope note first**: no production audio assets
  exist in this repo (see Assets below), and this sandbox has no way
  to author or license real ones, so an asset-based music/SFX player
  here would be exactly the fake functionality the project rules out —
  a player pointed at files that don't exist. Instead, `FeedbackService`
  uses Flutter's own built-in, asset-free feedback: `SystemSound` (a
  short native click/alert) and `HapticFeedback` (real device
  vibration). It's genuine, working feedback today; swapping in real
  asset-based sound later (e.g. via `audioplayers`) only means changing
  this one class, since every call site just says what *happened*
  (`SoundEvent.correct/incorrect/reward/purchase`), never *how* it
  sounds
- Wired into every place the game already knows something good, bad,
  or reward-worthy just happened: all 5 mini-games, quests, the parent
  gate, and shop purchases — both the sound and the settings gate share
  one `play()` call per site, so there's nothing to keep in sync
- New `SettingsRepository` (sound/haptics, both on by default) is
  checked live on every `play()` call, and Parent Zone now has toggles
  for both — a change takes effect on the very next event, not after a
  screen reload
- **Animations** — two small, reusable, pure-Flutter widgets (no new
  dependencies): `ShakeWidget` (a real horizontal shake, driven by an
  actual `TweenSequence`, not a fake placeholder) on every wrong-answer
  moment that didn't already have its own visual feedback (quests,
  Math Dash, Pattern Power, Memory Master, the parent gate — Word
  Builder and Find & Discover keep their existing letter-return/red-
  flash feedback rather than layering a second animation on top), and
  `PopIn` (a bouncy scale-in) on every mini-game's static results icon.
  Quest Complete already had its own real celebration animation from
  Phase 3 — left untouched, just given a matching reward sound
- Tests: `FeedbackService`'s full sound/haptic-to-event mapping and
  settings-gating (using injected spy functions, the same pattern as
  the play-time tracker's injectable clock), `SettingsRepository`
  persistence, both new widgets in isolation, and — to prove the
  wiring is actually connected, not just present — a handful of
  integration checks that a real wrong answer visibly shakes the
  screen in the quest flow, Math Dash, and the parent gate

**Phase 13** — Testing + Android release build (final phase; V1 content-complete):
- **Cleanup audit, since "final testing" is the right time to catch
  drift**: removed the `flame` dependency (declared since Phase 1,
  never actually imported anywhere — V1's screens never needed it) and
  a dead `PlaceholderScreen` widget (built in Phase 1 for routes ahead
  of their phase; every route has a real screen now, so nothing
  referenced it any more). Corrected `docs/PHASE_PLAN.md`'s V1-scope
  note, which had drifted to claim Space Mission content existed — it
  never did; only Jungle Adventure shipped. Explicitly resolved (as "not
  built, not silently dropped") the long-open Quick Challenge mini-game
  gap that never got a phase across 1–13
- Closed two real test-coverage gaps found by auditing every `lib/`
  file against `test/`: `RoomRepository` was missing the
  corrupted-save-data test every other JSON-backed repository already
  had, and `SharedPreferencesStorageService` — the actual production
  storage backend — had zero direct test coverage of its own; every
  other test exercises the hand-written `FakeLocalStorageService`
  stand-in instead. Both fixed
- Version bumped to `1.0.0+1` — this is the first release-candidate
  version number
- **`docs/RELEASE.md`**: a step-by-step runbook for turning this repo
  into a signed Android release — `flutter create`, app identity,
  icon, keystore/signing, the build commands, and a Play Store
  submission checklist (data safety, permissions, content rating).
  Written plainly as a runbook for **you** to execute with a real
  Flutter/Android toolchain, not as a claim that a build has happened —
  see the honest-limits note below
- **The unavoidable honest limit, repeated one final time because this
  is the phase named "testing" and "release build"**: no Flutter SDK
  has been available at any point across all 13 phases. Every line of
  Dart in this repo — all 76 `lib/` files and 45 `test/` files — has
  been written and reviewed, but never compiled, analyzed, or run.
  `flutter analyze` and `flutter test` have never actually executed
  against this code. This isn't a gap specific to Phase 13; it's been
  disclosed at the end of every phase, and it means step 2 of
  `docs/RELEASE.md` ("verify the app actually works first") is not a
  formality — it is the first real compile this code will ever see,
  and the most important thing to do before building, signing, or
  submitting anything

V1 is content-complete across all 13 planned phases. What's genuinely
left is what only a real toolchain can do: compiling it, running the
45-file test suite, and building/signing an actual release artifact.

**Phase 2 redesign** — after V1 shipped, Hero Selection / Home /
Adventure Map were revisited against a more detailed brief for that
area, adapting the existing architecture rather than rebuilding it so
Phase 3–13's quests, shop, and companions keep working unchanged:
- **First-run hero creation** is now a preset carousel
  (`HeroPresetSelectionScreen`, reached from Welcome's first **PLAY**):
  Previous/Next browse 8 original presets spanning every skin tone and
  a mix of accessories, Select confirms one, Continue saves it. No text
  entry anywhere. The existing swatch-by-swatch `HeroSelectionScreen`
  keeps its role unchanged as the detailed re-customize screen
  (reachable from the Room, and now also from Home's new **Customize**
  button) — picking a preset and later fine-tuning it is the same
  `HeroProfile` the whole way through, no separate preset model
- `HeroProfile` gained `skinToneId` (5 tones) and `accessoryId` (4
  accessories + "None"), both with backward-compatible JSON defaults so
  a hero saved before this redesign still loads instead of resetting.
  `HeroAvatarPreview` renders the chosen skin tone (previously a
  hardcoded color) and an emoji accessory overlay
- **Jungle Adventure** gained a sixth location, **Mountain** (locked,
  real 14 ⭐ threshold) between Lion Cave and Jungle Temple; its quest
  content isn't authored yet, so reaching it early shows a friendly
  "more adventures coming soon" screen rather than an empty or fake
  quest list. Monkey Camp now starts unlocked alongside Tree House
  (both 0 ⭐); Waterfall/Lion Cave/Jungle Temple's thresholds were
  rebalanced (6/10/16 ⭐) so the existing two-quests-per-location star
  economy still covers every step
- The Adventure Map now shows a real **completed** state (✓ and stars
  earned, computed live from `QuestRepository` vs. each location's
  quest list — never stored, same "derived, not saved" approach the
  badge system uses) alongside locked/unlocked, a small portrait of the
  child's own hero marking their furthest-unlocked location, and a
  gentle shake (reusing `ShakeWidget`) when a locked node is tapped.
  Every node now carries a semantic label describing its state, not
  just a color
- **Home** gained a Badges count (reusing `BadgeCatalog`/`BadgeStats`,
  the same live computation the Collection screen already used) and a
  direct **Customize** button, without removing the existing Mini-Games
  or My Collection entry points that weren't mentioned in the new brief
- Tests updated for the new unlock thresholds and 6-location map, plus
  new coverage for the preset catalog/screen, skin tone and accessory
  rendering, and the map's locked/unlocked/completed states and
  navigation (`test/adventure_map_screen_test.dart`)
- Same honest limit as every phase before it: no Flutter SDK has been
  available here, so none of this has been compiled, analyzed, or run
  — see Phase 13's note above, which still applies in full

**Phase 3 redesign** — the quest experience was likewise revisited
against a more detailed brief, deepening the existing quest engine
rather than replacing it (all 10 quests, the mini-games, and the reward
plumbing keep working):
- **Story dialogue system** (`StoryDialogue`, one reusable component for
  every quest): the quest's NPC — a new optional `QuestNpc` on the
  `Quest` model, e.g. 🐒 Momo the Monkey — speaks short lines one at a
  time with Next/Skip. Quests without authored dialogue fall back to
  their one-paragraph `storyIntro` as a single step, so nothing broke
- **Challenge framework**: `QuestChallenge` is now a sealed base type
  (prompt, options, gentle `hint`, story-item reward) with two concrete
  types — the existing `ChoiceChallenge` (emoji visual) and the new
  `MemoryChallenge` (study emoji as long as you like → "I'm ready!" →
  answer; no timer, so it can't feel rushed). Future types plug in the
  same way
- **Repair the Jungle Bridge** rebuilt to the brief: banana math (8−3)
  → jungle-friends memory (🐒🐼🦊🐰) → magical-lock pattern (🟢🔵🟢🔵❓),
  awarding Bridge Piece #1, Repair Tool, Bridge Piece #2, then a
  **story resolution sequence** (`QuestResolutionScreen`) where each
  tap pops in the next beat — pieces attach, bridge fixes, the baby
  monkey crosses — before the celebration
- **Tiered rewards, centralized** (`QuestRewardService`, never
  calculated in UI code): perfect no-miss run = base stars + 1 bonus
  (⭐⭐⭐) and 50 🪙; with retries = base stars (⭐⭐) and 35 🪙. Nothing
  is ever deducted for a wrong answer. `QuestRepository` now also
  records the stars each clear actually paid, so the map's "✓ N ⭐
  earned" caption shows real numbers
- **Mid-quest save/resume** (`QuestProgressRepository` + engine
  restore): backing out or killing the app mid-quest resumes at the
  start of the current challenge with the miss count intact (misses
  decide the reward tier, so they persist too). The quest list shows
  "Keep going — you're mid-adventure!" for the saved run, driven by a
  proper derived `QuestState` (locked/available/inProgress/completed —
  computed, never stored)
- Wrong answers now also surface each challenge's authored 💡 hint
  under the usual rotating encouragement
- Tests: engine resume/reward-tier coverage, `QuestRewardService`,
  `QuestProgressRepository` (round-trip, clear, corruption),
  `resolveQuestState`, `QuestRepository` stars-earned recording,
  `StoryDialogue` widget flow, and the full-flow widget test now walks
  dialogue → math → memory → pattern → bridge repair → celebration
- Same honest limit: no Flutter SDK available here — not compiled,
  analyzed, or run; Phase 13's note still applies in full

**Phase 4 redesign** — Math Dash was likewise deepened against a more
detailed brief ("Solve it. Collect it. Keep moving!"), reworking the
existing mini-game rather than replacing it:
- **`MathQuestion` model** (id, type, operands, correctAnswer, options,
  level, visual/object): the generator now returns questions carrying
  their own arithmetic facts, so the hint system and tests reason about
  the math directly instead of re-parsing prompt strings
- **Visual object system** (`MathObjects`): banana/apple/star/
  strawberry/coin, each defined once — small quantities render as
  countable object groups, never bare digits. Emoji remain the honest
  stand-in for real vector art (none exists in this repo yet)
- **Reusable hint system** (`MathHintService`, pure and unit-tested):
  a wrong answer now gets a real teaching hint — count hints for
  addition/comparison, step hints for subtraction (8 − 3 → "Count
  down: 8 → 7 → 6 → 5") and sequences — never just the answer
- **Sessions are 5 questions** with a top HUD (⭐ score, 🔥 streak,
  N / 5 progress), the hero on screen, and a jungle-gradient backdrop.
  The **streak counter** appears from 2-in-a-row; a miss resets it and
  nothing else. No timers anywhere
- **Rewards moved into the central reward service**
  (`QuestRewardService.calculateMathDash`): star at ~80% first-try
  correct (4 of 5), 5 coins with it, plus small streak bonuses (+1 for
  a 3-streak, +3 for a perfect streak). The screen only reports
  performance and pays what the service decides
- **Quest integration without coupling**: a new `MathDashChallenge`
  quest-challenge type lets any quest embed a short Math Dash session;
  the session pops a `MathDashResult` back and the Quest Engine counts
  a completed session as a solved challenge (the quest's own reward
  pays — embedded sessions never double-pay). Repair the Jungle
  Bridge's first challenge now embeds a 3-question banana-themed run
- Adaptive difficulty unchanged and still shared (`DifficultyTracker`);
  Robot's cross-out-an-option companion help unchanged
- Tests: generator rework (operand/answer consistency per type, unique
  ids, level bounds, visual objects), hint service (all four styles),
  reward tiers and thresholds, streak display/reset, embedded-session
  pop-with-result and no-double-pay, and the full-flow widget test now
  plays the real embedded Math Dash inside the bridge quest
- Same honest limit: no Flutter SDK available here — not compiled,
  analyzed, or run; Phase 13's note still applies in full

**Phase 5 redesign** — Memory Master was likewise deepened against a
more detailed brief ("Remember it. Find it. Win it!"), reworking the
existing mini-game rather than replacing it:
- **Jungle scene content** (`MemoryObjects`): 7 named friends (monkey,
  panda, fox, rabbit, parrot, frog, butterfly) placed at 7 named scene
  spots (by the tree, on the rock, at the waterfall, …), each shown as
  a little diorama card — discovering things in the jungle, not cards
  on a worksheet. Defined once; real art can replace emoji in one file
- **Question types rebuilt around the brief's headline pair**:
  *object recall* ("Which one did you see?" — decoys genuinely
  unseen) and *position recall* ("Where was the panda?" — answered
  with named spots a child can picture, not slot numbers), generated
  most often; missing-object, who-came-next, and how-many rounds add
  occasional variety. Items follow the spec: 3 at level 1, 4 at level
  2, 5 from level 3 (capped so decoys always exist; top levels trim
  study time slightly instead)
- **Observation phase**: "👀 Watch carefully!" with a soft animated
  fill bar — no numeric countdown anywhere; Panda's 1.5× extra-time
  companion help unchanged. A superseded-timer token keeps stale
  study timers from ever advancing a newer round
- **A real memory hint**: after a miss, a once-per-round "Look again"
  button replays a shorter peek at the scene, then returns to the same
  question — help that teaches looking carefully, never the answer
- **HUD + streak**: ⭐ score, 🧠 streak (from 2 remembered in a row),
  N / 5 progress — same layout and reset-only-the-streak behavior as
  Math Dash
- **Rewards and results through the shared services**: the Math Dash
  payout rule was generalized (`calculateMiniGameSession`,
  `MiniGameSessionResult`) and Memory Master reports into it — one
  payout rule, zero duplicated streak/reward logic
- **Quest integration**: new `MemoryMasterChallenge` embeds a session
  in any quest, same contract as `MathDashChallenge`; the bridge
  quest's memory moment is now a real 3-round embedded session. The
  authored `MemoryChallenge` type remains a supported one-off authoring
  option (covered by its own widget test)
- Tests: generator rework (distinct animals/spots, decoys genuinely
  unseen, position answers name the real spot, spec item counts, study
  timing), Look-again flow, streak chip, embedded pop-with-result and
  no-double-pay, and the full-flow widget test now plays both embedded
  sessions inside the bridge quest
- Same honest limit: no Flutter SDK available here — not compiled,
  analyzed, or run; Phase 13's note still applies in full

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
3. Tapping **PLAY** opens **Choose Your Hero**: a carousel of preset
   heroes (varied skin tones, hair, outfits, accessories — no typing, no
   name asked for). **Previous**/**Next** browse, **Select** confirms
   the one showing, **Continue** saves it and moves on.
4. Continuing goes to **Home**: your hero, ⭐/🪙/🏅 counts, and buttons
   for Adventure, Mini-Games, Collection, Companions, Room, and
   **Customize** (the detailed swatch-by-swatch editor, also reachable
   from the Room — pick skin tone, hair, outfit, shoes, backpack, and an
   accessory individually).
5. On the **Adventure Map**, both **Tree House** and **Monkey Camp**
   start unlocked; tap Tree House → a list of 2 quests. Locked locations
   show a lock icon, a gentle "Earn N more ⭐" hint on tap (with a small
   shake), and never rely on color alone to say so.
6. Play **Repair the Jungle Bridge**: Momo the Monkey tells the story
   in short dialogue lines (Next to advance, Skip to jump ahead), then
   **Start Adventure** → 3 challenges: an embedded 3-question **Math
   Dash** session ("The monkey needs bananas for the jungle camp!" →
   Play Math Dash!), an embedded 3-round **Memory Master** session
   ("The jungle friends are hiding!" → Play Memory Master!), and a
   magical-lock pattern.
   A wrong answer shows encouragement ("Almost! Let's try again!") plus
   a gentle 💡 hint and lets you retry; each solved challenge awards a
   story item (Bridge Piece #1, Repair Tool, Bridge Piece #2). Then the
   bridge-repair story plays out beat by beat — pieces attach, the
   bridge fixes, the baby monkey crosses — before the celebration
   screen. A no-quest-level-miss run pays **+3 ⭐ +50 🪙**; a run with
   retries still pays **+2 ⭐ +35 🪙** (retrying is never punished).
7. Back on the map, your stars now count toward unlocks: **Waterfall**
   opens at 6 ⭐, **Lion Cave** at 10 ⭐, **Mountain** at 14 ⭐ (real and
   locked, but its own quests aren't authored yet — opening it early
   shows a friendly "more adventures coming soon" screen instead of a
   fake quest list), and **Jungle Temple** at 16 ⭐. A completed
   location shows a ✓ badge and its stars earned instead of a lock
   hint. Your hero also appears as a small marker at your furthest
   unlocked location.
8. Replay a completed quest: it's marked "Completed! Play again for
   practice" and awards no extra stars. Quit mid-quest instead (back
   button, or kill the app) and the quest list shows "Keep going —
   you're mid-adventure!"; reopening resumes at the start of the
   challenge you were on, misses remembered.
9. From **Home**, tap **Mini-Games** → **Math Dash** ("Solve it.
   Collect it. Keep moving!"): the intro states the reward rule ("Get 4
   right on the first try to earn a ⭐"), then a 5-question session
   with your hero on screen — small counts appear as countable objects
   (bananas, apples, stars, strawberries, coins). The top HUD shows ⭐
   score, 🔥 streak (from 2 in a row), and progress N / 5. A miss shows
   encouragement plus a 💡 hint (subtraction counts down step by step:
   8 → 7 → 6 → 5) and resets the streak — nothing earned is ever
   removed. Results show score, best streak, and the payout (perfect
   streak earns bonus coins). Answer 3 in a row correctly across
   sessions and the questions quietly get harder; struggle and they
   ease off.
10. Back at Mini-Games, try **Memory Master** ("Remember it. Find it.
    Win it!"): jungle friends appear at named scene spots (🐒 by the
    tree, 🐼 on the rock…) with a soft progress bar — no numeric
    countdown — then hide. Questions ask which one you saw, where the
    panda was, who you did NOT see, who came next, or how many. The HUD
    shows ⭐ score, 🧠 streak, and N / 5. A miss offers a once-per-round
    "Look again" peek at the scene. 4 of 5 first-try correct earns a ⭐
    (streak bonuses add coins, same payout rule as Math Dash).
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
31. Answer a question wrong anywhere it wasn't already handled (a
    quest, Math Dash, Pattern Power, Memory Master, the parent gate):
    the options/prompt actually shake, and — on a real device with the
    volume up and haptics on — you'll feel/hear it too. Every mini-game's
    results screen now pops its trophy/face icon in with a little
    bounce instead of just appearing.
32. In Parent Zone, toggle **Sound Effects** and **Haptic Feedback**
    off. Go play — no more click/vibration on answers. Turn them back
    on and they resume immediately, no restart needed.
33. `flutter test` passes (all widget + unit tests) — this is the
    **first time** this exact command has ever run against this code;
    see Phase 13's notes above.
34. `flutter analyze` reports no errors.
35. Ready to actually ship it? Follow `docs/RELEASE.md` end to end.

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
    audio/                   # SoundEvent, FeedbackService (system sound + haptics)
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
                              # ShopRepository, RoomRepository, PlayTimeRepository,
                              # SettingsRepository
    worlds/                  # JungleWorld (Space/Dino/Magic/Robot: later)
    systems/                 # QuestEngine, DifficultyTracker, all 5 puzzle generators,
                              # ParentGateChallengeGenerator
    quests/                  # JungleQuests content (10 quests, data only)
  shared/
    widgets/                 # BigRoundedButton, ShakeWidget, PopIn, ...
test/
  game/                     # unit tests for repositories + models
  core/                     # DurationFormatter, PlayTimeTracker, FeedbackService
  shared/                   # ShakeWidget, PopIn
  support/                  # FakeLocalStorageService
```

## Assets

No production art/audio is included yet. The hero avatar and map icons
are all drawn in code (colored shapes + Material icons), not
illustrations — see `lib/features/player/hero_avatar_preview.dart` and
`lib/game/worlds/jungle_world.dart`. No copyrighted third-party
characters are used anywhere in this project. A real asset manifest will
be added once professional art starts replacing these placeholders.
Sound is likewise not asset-based yet — Phase 12's `FeedbackService`
uses Flutter's built-in `SystemSound`/`HapticFeedback` for genuine,
working feedback without needing licensed audio files; see Phase 12's
README section above for why, and how it's structured so real
asset-based sound can replace it later without touching call sites.
