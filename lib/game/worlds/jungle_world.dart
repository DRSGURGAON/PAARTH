import 'package:flutter/material.dart';

import '../models/world_location.dart';

/// World 1 — the only fully-built world in V1 (see
/// docs/GAME_DESIGN_BRIEF.md). Star thresholds are an initial balance
/// guess for a 5-location world reachable through Phase 3+'s quests;
/// tune once quests actually award stars.
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
      requiredStars: 3,
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
      requiredStars: 9,
    ),
    WorldLocation(
      id: 'jungle_temple',
      name: 'Jungle Temple',
      icon: Icons.account_balance_rounded,
      requiredStars: 12,
    ),
  ];
}
