import 'package:flutter/material.dart';

import '../models/world_location.dart';

/// World 1 — the only fully-built world in V1 (see
/// docs/GAME_DESIGN_BRIEF.md). Six locations reachable through Phase 3+'s
/// quests. Tree House and Monkey Camp start unlocked (Phase 2 redesign
/// brief section 5); every later threshold is chosen so the two quests
/// at each already-open location always earn enough stars to cover the
/// next one — see `jungle_quests_test.dart`'s star-economy check.
///
/// Mountain is a real, honestly-locked location with its own threshold,
/// not a fake placeholder — but no quest content has been authored for
/// it yet (scope exclusion for this redesign, same "designed, not built"
/// pattern the other worlds use in the design brief). Reaching it before
/// quests are added shows a friendly "coming soon" state rather than an
/// empty list — see `LocationQuestsScreen`.
class JungleWorld {
  JungleWorld._();

  static const String worldId = 'jungle_adventure';
  static const String worldName = 'Jungle Adventure';

  static const List<WorldLocation> locations = [
    WorldLocation(
      id: 'tree_house',
      name: 'Tree House',
      icon: Icons.holiday_village_rounded,
      requiredStars: 0,
    ),
    WorldLocation(
      id: 'monkey_camp',
      name: 'Monkey Camp',
      icon: Icons.pets_rounded,
      requiredStars: 0,
    ),
    WorldLocation(
      id: 'waterfall',
      name: 'Waterfall',
      icon: Icons.water_drop_rounded,
      requiredStars: 6,
    ),
    WorldLocation(
      id: 'lion_cave',
      name: 'Lion Cave',
      icon: Icons.terrain_rounded,
      requiredStars: 10,
    ),
    WorldLocation(
      id: 'mountain',
      name: 'Mountain',
      icon: Icons.landscape_rounded,
      requiredStars: 14,
    ),
    WorldLocation(
      id: 'jungle_temple',
      name: 'Jungle Temple',
      icon: Icons.account_balance_rounded,
      requiredStars: 16,
    ),
  ];
}
