import 'package:flutter/material.dart';

/// One collectible badge (design brief section 11's "🏅 Badges" /
/// "🎒 Collection"). Pure display data — whether it's earned is a
/// derived fact, not something stored on the badge itself (see
/// `BadgeCatalog`).
class GameBadge {
  const GameBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
}
