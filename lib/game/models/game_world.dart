import 'world_location.dart';

/// One adventure world (Jungle, Space, ...): identity, the total-star
/// threshold that unlocks it, and its map locations. Pure data — the
/// world-select and map screens render whatever the registry
/// (`game/worlds/worlds.dart`) provides, so adding a world never
/// touches screen code.
class GameWorld {
  const GameWorld({
    required this.id,
    required this.name,
    required this.emoji,
    required this.tagline,
    required this.requiredStars,
    required this.locations,
  });

  final String id;
  final String name;
  final String emoji;
  final String tagline;

  /// Total stars needed before this world opens (0 = always open).
  final int requiredStars;

  final List<WorldLocation> locations;

  bool isUnlockedFor(int stars) => stars >= requiredStars;
}
