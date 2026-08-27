import 'package:flutter/material.dart';

import '../models/game_world.dart';
import '../models/world_location.dart';

/// World 4 — Magic Kingdom.
class MagicWorld {
  MagicWorld._();

  static const String worldId = 'magic_kingdom';

  static const GameWorld world = GameWorld(
    id: worldId,
    name: 'Magic Kingdom',
    emoji: '🏰',
    tagline: 'Sparkles, spells, and smiles!',
    requiredStars: 62,
    locations: [
      WorldLocation(
        id: 'castle_gate',
        name: 'Castle Gate',
        icon: Icons.fort_rounded,
        requiredStars: 62,
      ),
      WorldLocation(
        id: 'enchanted_forest',
        name: 'Enchanted Forest',
        icon: Icons.forest_rounded,
        requiredStars: 62,
      ),
      WorldLocation(
        id: 'wizard_tower',
        name: 'Wizard Tower',
        icon: Icons.auto_fix_high_rounded,
        requiredStars: 68,
      ),
      WorldLocation(
        id: 'treasure_cave',
        name: 'Treasure Cave',
        icon: Icons.diamond_rounded,
        requiredStars: 72,
      ),
      WorldLocation(
        id: 'royal_castle',
        name: 'Royal Castle',
        icon: Icons.castle_rounded,
        requiredStars: 76,
      ),
    ],
  );
}
