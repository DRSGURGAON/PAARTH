import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/companion.dart';
import '../repositories/mini_game_repository.dart';

/// Canonical companion ids, shared between the catalog, the repository
/// that stores which one is equipped, and every mini-game screen that
/// checks whether its own helper is active.
class CompanionIds {
  CompanionIds._();

  static const String robot = 'robot';
  static const String fox = 'fox';
  static const String panda = 'panda';
  static const String monkey = 'monkey';
  static const String puppy = 'puppy';

  static const List<String> all = [robot, fox, panda, monkey, puppy];
}

/// The 5 V1 companions (design brief section 10) and the real,
/// gameplay-affecting help each gives once equipped:
///
/// - Robot: math hint in Math Dash (crosses out one wrong answer)
/// - Fox: puzzle hint in Pattern Power (crosses out one wrong answer)
/// - Panda: extra study time in Memory Master
/// - Monkey: points at one hidden object in Find & Discover
/// - Puppy: sniffs out the first letter in Word Builder
///
/// A companion unlocks by earning a star in the mini-game it goes on to
/// help with — proof the child can already do it without help. Like
/// badges, "unlocked" is never stored on the companion itself; it's
/// recomputed from real mini-game progress every time (see
/// [unlockedCompanionIds]).
class CompanionCatalog {
  CompanionCatalog._();

  static const List<Companion> all = [
    Companion(
      id: CompanionIds.robot,
      name: 'Robot',
      description: 'Earn a star in Math Dash to unlock Robot.',
      abilityLabel: 'Crosses out one wrong answer in Math Dash.',
      icon: Icons.smart_toy_rounded,
      color: AppColors.skyBlue,
      unlockMiniGameId: MiniGameIds.mathDash,
    ),
    Companion(
      id: CompanionIds.fox,
      name: 'Fox',
      description: 'Earn a star in Pattern Power to unlock Fox.',
      abilityLabel: 'Crosses out one wrong answer in Pattern Power.',
      icon: Icons.pets_rounded,
      color: AppColors.grapePurple,
      unlockMiniGameId: MiniGameIds.patternPower,
    ),
    Companion(
      id: CompanionIds.panda,
      name: 'Panda',
      description: 'Earn a star in Memory Master to unlock Panda.',
      abilityLabel: 'Gives extra time to study in Memory Master.',
      icon: Icons.cruelty_free_rounded,
      color: AppColors.coral,
      unlockMiniGameId: MiniGameIds.memoryMaster,
    ),
    Companion(
      id: CompanionIds.monkey,
      name: 'Monkey',
      description: 'Earn a star in Find & Discover to unlock Monkey.',
      abilityLabel: 'Points out one hidden object in Find & Discover.',
      icon: Icons.emoji_nature_rounded,
      color: AppColors.leafGreen,
      unlockMiniGameId: MiniGameIds.findDiscover,
    ),
    Companion(
      id: CompanionIds.puppy,
      name: 'Puppy',
      description: 'Earn a star in Word Builder to unlock Puppy.',
      abilityLabel: 'Sniffs out the first letter in Word Builder.',
      icon: Icons.favorite_rounded,
      color: AppColors.sunshineYellow,
      unlockMiniGameId: MiniGameIds.wordBuilder,
    ),
  ];

  static Set<String> unlockedCompanionIds(Set<String> starEarnedGameIds) => {
        for (final companion in all)
          if (starEarnedGameIds.contains(companion.unlockMiniGameId))
            companion.id,
      };
}
