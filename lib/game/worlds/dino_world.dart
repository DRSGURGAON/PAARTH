import 'package:flutter/material.dart';

import '../models/game_world.dart';
import '../models/world_location.dart';

/// World 3 — Dino Island.
class DinoWorld {
  DinoWorld._();

  static const String worldId = 'dino_island';

  static const GameWorld world = GameWorld(
    id: worldId,
    name: 'Dino Island',
    emoji: '🦕',
    tagline: 'Roar with the friendly dinos!',
    requiredStars: 42,
    locations: [
      WorldLocation(
        id: 'dino_camp',
        name: 'Dino Camp',
        icon: Icons.cabin_rounded,
        requiredStars: 42,
      ),
      WorldLocation(
        id: 'fossil_valley',
        name: 'Fossil Valley',
        icon: Icons.museum_rounded,
        requiredStars: 42,
      ),
      WorldLocation(
        id: 'volcano',
        name: 'Volcano',
        icon: Icons.local_fire_department_rounded,
        requiredStars: 48,
      ),
      WorldLocation(
        id: 'dino_nest',
        name: 'Dino Nest',
        icon: Icons.egg_rounded,
        requiredStars: 52,
      ),
      WorldLocation(
        id: 'ancient_temple',
        name: 'Ancient Temple',
        icon: Icons.temple_hindu_rounded,
        requiredStars: 56,
      ),
    ],
  );
}
