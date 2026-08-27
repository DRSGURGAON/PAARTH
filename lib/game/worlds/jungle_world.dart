import 'package:flutter/material.dart';

import '../models/game_world.dart';
import '../models/world_location.dart';

/// World 1 — always open. Tree House and Monkey Camp start unlocked;
/// every later threshold is chosen so the quests at already-open
/// locations always earn enough stars to cover the next one — see the
/// star-economy test in `world_quests_test.dart`.
class JungleWorld {
  JungleWorld._();

  static const String worldId = 'jungle_adventure';
  static const String worldName = 'Jungle Adventure';

  static const GameWorld world = GameWorld(
    id: worldId,
    name: worldName,
    emoji: '🌴',
    tagline: 'Where every Super Kid begins!',
    requiredStars: 0,
    locations: locations,
  );

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
