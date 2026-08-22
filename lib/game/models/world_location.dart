import 'package:flutter/material.dart';

/// One tappable spot on a world's Adventure Map (e.g. Jungle's "Tree
/// House"). Pure data — no widget/asset references — so worlds can be
/// declared as plain lists (see `game/worlds/`) and new ones added
/// without touching the map screen.
class WorldLocation {
  const WorldLocation({
    required this.id,
    required this.name,
    required this.icon,
    required this.requiredStars,
  });

  final String id;
  final String name;
  final IconData icon;

  /// Stars the child must have earned for this location to be tappable.
  /// The first location in a world is always 0 (the entry point).
  final int requiredStars;

  bool isUnlockedFor(int stars) => stars >= requiredStars;
}
