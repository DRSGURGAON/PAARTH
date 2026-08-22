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
- [ ] **Phase 10** — Parent Zone
- [ ] **Phase 11** — Save system + offline persistence
- [ ] **Phase 12** — Polish: animations + sound
- [ ] **Phase 13** — Testing + Android release build

V1 scope: Jungle Adventure (fully playable) + the start of Space Mission.
Worlds 3–5 (Dino Island, Magic Kingdom, Robot City) are designed in the
brief but intentionally not built in V1 — the architecture must allow
adding them later without rewriting existing code.

**Open gap:** the brief's Quick Challenge mini-game type (20–30s
tap/count/match/avoid activities; section 21 wants 10 of them) has no
phase of its own here. Needs a decision on which phase absorbs it.
