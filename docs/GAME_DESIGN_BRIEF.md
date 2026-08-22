# Super Kid Adventure — Game Design Brief

Condensed reference for ongoing development. This is the source of truth
for what each future phase should build; see `PHASE_PLAN.md` for status.

## Premise

Target player: ~6–9 years old (Class 2 / age 7 focus). Not a quiz app —
a colorful adventure game where learning is embedded in quests
("the jungle bridge is broken, help repair it" → small educational
challenges solve the story problem), never presented as bare test
questions.

## Tech constraints

Flutter + Dart, Flame where appropriate, Android-first (architected for
iOS later), offline-first with local persistence, no backend/account for
V1, clean modular architecture, no unnecessary dependencies, no
copyrighted third-party characters.

## Worlds (only Jungle Adventure + start of Space Mission ship in V1)

1. **Jungle Adventure** — Tree House, Monkey Camp, Waterfall, Lion Cave,
   Mountain, Jungle Temple (Mountain has no quest content yet — designed,
   not built, same as the worlds below)
2. **Space Mission** — Space Station, Moon Base, Alien Garden, Asteroid
   Field, Space Portal
3. **Dino Island** *(designed, not built)* — Dino Camp, Fossil Valley,
   Volcano, Dino Nest, Ancient Temple
4. **Magic Kingdom** *(designed, not built)* — Castle Gate, Enchanted
   Forest, Wizard Tower, Treasure Cave, Royal Castle
5. **Robot City** *(designed, not built)* — Robot Garage, Energy Factory,
   Sky Bridge, Robot Lab, Mega Core

## Core loop

Explore → discover quest → complete interactive challenges → solve
problem → earn stars/coins → unlock rewards → explore more → unlock new
area. Always a clear short-term goal.

## Hero & companions

Customizable hero (hair/outfit/shoes/backpack/accessories), no personal
info required. Companions: Monkey (finds hidden objects), Fox (puzzle
hint), Panda (memory-game assist), Puppy (finds collectibles), Robot
(math hint). No gambling/loot boxes.

## Quest structure (example: Repair the Jungle Bridge)

Story hook → 2–3 embedded mini-game challenges (math / memory / pattern)
→ each success yields a story item (bridge piece, tool) → animated
resolution → stars + coins + reward. The child should feel *they* solved
the adventure problem, not that they answered quiz questions.

## Mini-game types

- **Math Dash** — addition/subtraction/comparison/sequences (V1);
  multiplication/division/fractions/time/money later. Visual objects
  (🍎🍎🍎 + 🍎🍎) preferred over bare digits.
- **Memory Master** — remember position/sequence/object/number.
- **Pattern Power** — visual and numeric sequence completion.
- **Word Builder** — letter arrangement/spelling with picture cues.
- **Find & Discover** — tap-to-find in an interactive scene.
- **Quick Challenge** — 20–30s tap/count/match/avoid activities.

All non-violent, child-friendly. Difficulty adapts per-subject (math,
memory, logic, English) based on recent performance; never punitive
language on failure ("Almost! Let's try again!" not "Wrong!").

## Reward system

Stars, coins, badges, collectibles, companions, customization. Coins
unlock clothes/hats/shoes/backpacks/room decor/companion accessories.
No gambling, no loot boxes — rewards are predictable.

## Player room

Persistent decorable space (bed/desk/toys/plants/posters/trophies);
achievements appear visually here.

## World boss

Non-violent finale per world combining math/memory/pattern/word
challenges; the "boss" ends up friendly/helpful, not defeated violently.

## Parent Zone

Behind an age-appropriate parent gate (V1: simple gate, designed to be
replaceable with something stronger later). Shows play time, quests
completed, per-subject progress, recommended practice area. Any future
purchase flow must live behind this gate.

## Child safety (hard requirements)

No chat, public profiles, social messaging, location tracking, contact
access, unnecessary camera/mic access, personal data collection,
gambling, loot boxes, violence, horror, or manipulative purchase
prompts. No real name/phone/email/location ever requested.

## Architecture (lib/)

```
core/        audio, storage, theme, constants, utils, navigation, di
game/        models, systems, quests, worlds, mini_games, rewards, companions
features/    home, adventure_map, player, room, parent_zone, splash, welcome
shared/      widgets
```

Business logic stays out of widgets; content (questions, quests) is data
that can be added to without touching UI code.

## Monetization (architecture only — not built in V1)

Free tier (limited content) / Premium (full game), parent-gated
purchases only, no aggressive ads in the prototype, modular enough to add
after gameplay validation.
