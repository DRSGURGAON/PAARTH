import 'package:flutter/material.dart';

import '../models/game_world.dart';
import '../models/world_location.dart';

/// World 2 — Space Mission. Opens once the child has 20 stars (well
/// under the Jungle's earnable total, so it's always reachable).
class SpaceWorld {
  SpaceWorld._();

  static const String worldId = 'space_mission';

  static const GameWorld world = GameWorld(
    id: worldId,
    name: 'Space Mission',
    emoji: '🚀',
    tagline: 'Blast off, Super Kid!',
    requiredStars: 20,
    locations: [
      WorldLocation(
        id: 'space_station',
        name: 'Space Station',
        icon: Icons.satellite_alt_rounded,
        requiredStars: 20,
      ),
      WorldLocation(
        id: 'moon_base',
        name: 'Moon Base',
        icon: Icons.nightlight_rounded,
        requiredStars: 20,
      ),
      WorldLocation(
        id: 'alien_garden',
        name: 'Alien Garden',
        icon: Icons.local_florist_rounded,
        requiredStars: 26,
      ),
      WorldLocation(
        id: 'asteroid_field',
        name: 'Asteroid Field',
        icon: Icons.blur_circular_rounded,
        requiredStars: 30,
      ),
      WorldLocation(
        id: 'space_portal',
        name: 'Space Portal',
        icon: Icons.motion_photos_on_rounded,
        requiredStars: 34,
      ),
    ],
  );
}
