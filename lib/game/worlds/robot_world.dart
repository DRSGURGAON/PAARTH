import 'package:flutter/material.dart';

import '../models/game_world.dart';
import '../models/world_location.dart';

/// World 5 — Robot City, the final V2 world.
class RobotWorld {
  RobotWorld._();

  static const String worldId = 'robot_city';

  static const GameWorld world = GameWorld(
    id: worldId,
    name: 'Robot City',
    emoji: '🤖',
    tagline: 'Beep boop — build and learn!',
    requiredStars: 82,
    locations: [
      WorldLocation(
        id: 'robot_garage',
        name: 'Robot Garage',
        icon: Icons.garage_rounded,
        requiredStars: 82,
      ),
      WorldLocation(
        id: 'energy_factory',
        name: 'Energy Factory',
        icon: Icons.bolt_rounded,
        requiredStars: 82,
      ),
      WorldLocation(
        id: 'sky_bridge',
        name: 'Sky Bridge',
        icon: Icons.cloud_rounded,
        requiredStars: 88,
      ),
      WorldLocation(
        id: 'robot_lab',
        name: 'Robot Lab',
        icon: Icons.science_rounded,
        requiredStars: 92,
      ),
      WorldLocation(
        id: 'mega_core',
        name: 'Mega Core',
        icon: Icons.memory_rounded,
        requiredStars: 96,
      ),
    ],
  );
}
