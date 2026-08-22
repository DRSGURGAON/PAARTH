import 'package:flutter/material.dart';

/// One companion character (design brief section 10). A child unlocks
/// a companion by earning a star in the mini-game it's paired with,
/// then can equip at most one as their active helper — see
/// [CompanionCatalog] for the unlock rule and [CompanionRepository] for
/// the equipped choice.
class Companion {
  const Companion({
    required this.id,
    required this.name,
    required this.description,
    required this.abilityLabel,
    required this.icon,
    required this.color,
    required this.unlockMiniGameId,
  });

  final String id;
  final String name;
  final String description;
  final String abilityLabel;
  final IconData icon;
  final Color color;

  /// The `MiniGameIds` value a child must have earned a star in before
  /// this companion is unlocked.
  final String unlockMiniGameId;
}
