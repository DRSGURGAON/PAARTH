import 'package:flutter/material.dart';

import '../models/badge.dart';
import '../models/quest.dart';
import '../quests/dino_quests.dart';
import '../quests/jungle_quests.dart';
import '../quests/magic_quests.dart';
import '../quests/robot_quests.dart';
import '../quests/space_quests.dart';
import '../repositories/mini_game_repository.dart';

/// Everything a badge's earned-condition might need to check. Plain
/// data holder — callers gather these from the relevant repositories
/// once, so [BadgeCatalog.earnedBadges] never touches storage itself.
class BadgeStats {
  const BadgeStats({
    required this.completedQuestIds,
    required this.miniGameStarIds,
    required this.totalStars,
    required this.totalCoins,
  });

  final Set<String> completedQuestIds;
  final Set<String> miniGameStarIds;
  final int totalStars;
  final int totalCoins;
}

class _BadgeDefinition {
  const _BadgeDefinition(this.badge, this.isEarned);

  final GameBadge badge;
  final bool Function(BadgeStats stats) isEarned;
}

/// True when every quest in [quests] is in the completed set — each
/// world's explorer badge checks its own quest ids, never a bare
/// count, so finishing 13 quests scattered across worlds can't earn
/// the wrong world's badge.
bool _completedAll(BadgeStats stats, List<Quest> quests) =>
    quests.every((quest) => stats.completedQuestIds.contains(quest.id));

/// The full set of V1 badges and the (deterministic, non-random)
/// condition that earns each one. Earned status is never stored — it's
/// recomputed from real progress every time, so a badge can never say
/// "earned" for something that didn't actually happen.
class BadgeCatalog {
  BadgeCatalog._();

  static final List<_BadgeDefinition> _definitions = [
    _BadgeDefinition(
      const GameBadge(
        id: 'first_quest',
        name: 'First Quest',
        description: 'Complete your first adventure quest.',
        icon: Icons.flag_rounded,
      ),
      (stats) => stats.completedQuestIds.isNotEmpty,
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'jungle_explorer',
        name: 'Jungle Explorer',
        description: 'Complete every quest in Jungle Adventure.',
        icon: Icons.forest_rounded,
      ),
      (stats) => _completedAll(stats, JungleQuests.all),
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'space_explorer',
        name: 'Space Explorer',
        description: 'Complete every quest in Space Mission.',
        icon: Icons.rocket_launch_rounded,
      ),
      (stats) => _completedAll(stats, SpaceQuests.all),
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'dino_explorer',
        name: 'Dino Explorer',
        description: 'Complete every quest on Dino Island.',
        icon: Icons.pets_rounded,
      ),
      (stats) => _completedAll(stats, DinoQuests.all),
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'magic_explorer',
        name: 'Magic Explorer',
        description: 'Complete every quest in Magic Kingdom.',
        icon: Icons.castle_rounded,
      ),
      (stats) => _completedAll(stats, MagicQuests.all),
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'robot_explorer',
        name: 'Robot Explorer',
        description: 'Complete every quest in Robot City.',
        icon: Icons.smart_toy_rounded,
      ),
      (stats) => _completedAll(stats, RobotQuests.all),
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'math_whiz',
        name: 'Math Whiz',
        description: 'Earn a star in Math Dash.',
        icon: Icons.calculate_rounded,
      ),
      (stats) => stats.miniGameStarIds.contains(MiniGameIds.mathDash),
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'memory_master_badge',
        name: 'Memory Master',
        description: 'Earn a star in Memory Master.',
        icon: Icons.psychology_rounded,
      ),
      (stats) => stats.miniGameStarIds.contains(MiniGameIds.memoryMaster),
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'pattern_pro',
        name: 'Pattern Pro',
        description: 'Earn a star in Pattern Power.',
        icon: Icons.pattern_rounded,
      ),
      (stats) => stats.miniGameStarIds.contains(MiniGameIds.patternPower),
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'word_wizard',
        name: 'Word Wizard',
        description: 'Earn a star in Word Builder.',
        icon: Icons.spellcheck_rounded,
      ),
      (stats) => stats.miniGameStarIds.contains(MiniGameIds.wordBuilder),
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'eagle_eye',
        name: 'Eagle Eye',
        description: 'Earn a star in Find & Discover.',
        icon: Icons.search_rounded,
      ),
      (stats) => stats.miniGameStarIds.contains(MiniGameIds.findDiscover),
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'lightning_kid',
        name: 'Lightning Kid',
        description: 'Earn a star in Quick Challenge.',
        icon: Icons.bolt_rounded,
      ),
      (stats) => stats.miniGameStarIds.contains(MiniGameIds.quickChallenge),
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'star_collector',
        name: 'Star Collector',
        description: 'Earn 20 stars in total.',
        icon: Icons.star_rounded,
      ),
      (stats) => stats.totalStars >= 20,
    ),
    _BadgeDefinition(
      const GameBadge(
        id: 'coin_collector',
        name: 'Coin Collector',
        description: 'Earn 20 coins in total.',
        icon: Icons.monetization_on_rounded,
      ),
      (stats) => stats.totalCoins >= 20,
    ),
  ];

  /// "Collect them all" capstone. Kept separate from [_definitions] so
  /// its own condition (earn every other badge) can't accidentally
  /// depend on itself.
  static const GameBadge _superKidBadge = GameBadge(
    id: 'super_kid',
    name: 'Super Kid',
    description: 'Earn every other badge.',
    icon: Icons.workspace_premium_rounded,
  );

  static List<GameBadge> get all => [
        for (final d in _definitions) d.badge,
        _superKidBadge,
      ];

  static Set<String> earnedBadgeIds(BadgeStats stats) {
    final earned = {
      for (final d in _definitions)
        if (d.isEarned(stats)) d.badge.id,
    };
    if (earned.length >= _definitions.length) earned.add(_superKidBadge.id);
    return earned;
  }
}
