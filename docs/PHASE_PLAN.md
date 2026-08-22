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

V1 scope, as actually shipped: **Jungle Adventure only**, fully playable
(6 locations after the post-V1 Phase 2 redesign added Mountain — 10
quests across the 5 locations that have quest content, Mountain's not
authored yet; all 5 mini-games, rewards, companions, room customization,
Parent Zone, save/reset, and the animation+sound polish of Phase 12).
Worlds 2–5 (Space Mission, Dino Island, Magic Kingdom,
Robot City) are designed in the brief but intentionally not built —
`game/worlds/jungle_world.dart` establishes the pattern a `space_world.dart`
etc. would follow later without rewriting existing code, but no Space
Mission content exists yet. (An earlier draft of this doc said V1
included "the start of Space Mission" — that was aspirational and never
actually built; corrected here in Phase 13.)

**Resolved gap:** the brief's Quick Challenge mini-game type (20–30s
tap/count/match/avoid activities; section 21 wants 10 of them) never got
a phase of its own across Phases 1–13 and is not part of this V1 release.
Flagging it here explicitly rather than leaving it silently dropped: a
V2 could add it as its own phase, following the same
model+generator+screen pattern as the 5 built mini-games.

**Also resolved in Phase 13:** the `flame` package was declared as a
dependency from Phase 1 onward ("Flame where appropriate") but no
screen ever actually needed it — every V1 screen is plain Flutter UI.
Removed from `pubspec.yaml` rather than kept as an unused dependency;
a future phase that builds a scrolling/physics world can reintroduce it
when there's real code to justify it.
