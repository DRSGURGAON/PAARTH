# Phase Plan

Built one phase at a time; each phase must compile (`flutter analyze`
clean, `flutter test` green) before the next begins.

- [x] **Phase 1** — Project setup + architecture + theme + navigation
- [x] **Phase 2** — Hero + home + adventure map
- [x] **Phase 3** — Quest engine
- [x] **Phase 4** — Math Dash mini-game
- [x] **Phase 5** — Memory Master + Pattern Power mini-games
- [x] **Phase 6** — Word Builder + Find & Discover mini-games
- [x] **Phase 7** — Rewards (stars, coins, badges)
- [x] **Phase 8** — Companions
- [x] **Phase 9** — Player room + character customization
- [x] **Phase 10** — Parent Zone
- [x] **Phase 11** — Save system + offline persistence
- [x] **Phase 12** — Polish: animations + sound
- [x] **Phase 13** — Testing + Android release build

Post-V1 redesign phases (deepening shipped areas against more detailed
briefs; see the README's redesign sections):

- [x] **Phase 2 redesign** — preset hero creation, skin tones, 6-location map
- [x] **Phase 3 redesign** — story dialogue, tiered rewards, mid-quest resume
- [x] **Phase 4 redesign** — Math Dash: visual objects, streaks, hints, quest embedding
- [x] **Phase 5 redesign** — Memory Master: jungle scenes, recall types, look-again
- [x] **Phase 6 redesign** — Pattern Power: themed patterns, structure ladder, lock
- [x] **Phase 8 (activities)** — dashboard Chess + Piano + Guitar
- [x] **All-worlds completion pass** — Mountain quests + jungle boss,
  Worlds 2–5 (Space Mission, Dino Island, Magic Kingdom, Robot City)
  with full quest content and world-boss finales, world-select screen,
  Quick Challenge mini-game + Cheetah companion, per-world explorer
  badges

V1 scope, as actually shipped: **Jungle Adventure only**, fully playable
(6 locations after the post-V1 Phase 2 redesign added Mountain; all 5
mini-games, rewards, companions, room customization, Parent Zone,
save/reset, and the animation+sound polish of Phase 12). The all-worlds
completion pass then built everything the brief designed but V1
deferred: Mountain's two quests, a boss quest per world, Worlds 2–5
(two quests per location, `game/quests/quest_catalog.dart` merging all
five worlds' content, `game/worlds/worlds.dart` registry, a world-select
screen in front of the per-world map), with unlock thresholds
stair-stepped so each world is reachable from base quest rewards alone
(`test/game/world_quests_test.dart` proves it).

**Resolved gap (now built):** the brief's Quick Challenge mini-game type
(20–30s tap/count/match/avoid activities; section 21 wants 10 of them)
never got a phase of its own across Phases 1–13 and shipped later in the
all-worlds completion pass: ten authored templates in
`game/systems/quick_challenge_generator.dart`, a gentle 25-second round
timer that resets with encouragement instead of punishing, the same
session-reward math as the other mini-games, and the Cheetah companion
(extra round seconds) unlocked by its star.

**Also resolved in Phase 13:** the `flame` package was declared as a
dependency from Phase 1 onward ("Flame where appropriate") but no
screen ever actually needed it — every V1 screen is plain Flutter UI.
Removed from `pubspec.yaml` rather than kept as an unused dependency;
a future phase that builds a scrolling/physics world can reintroduce it
when there's real code to justify it.
