import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/badge_catalog.dart';
import '../../game/data/companion_catalog.dart';
import '../../game/models/companion.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/companion_repository.dart';
import '../../game/repositories/hero_repository.dart';
import '../../game/repositories/mini_game_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/repositories/quest_repository.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../player/hero_avatar_preview.dart';

/// Landing spot after the hero is created: shows the hero, current
/// stars, coins and badges, and the next actions — Adventure Map,
/// Mini-Games, Collection, Companions, Room, and Customize. Stateful so
/// the currency badges refresh when the child comes back from earning
/// more.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openAdventureMap() async {
    await Navigator.of(context).pushNamed(RouteNames.adventureMap);
    if (mounted) setState(() {});
  }

  Future<void> _openMiniGames() async {
    await Navigator.of(context).pushNamed(RouteNames.miniGames);
    if (mounted) setState(() {});
  }

  Future<void> _openCollection() async {
    await Navigator.of(context).pushNamed(RouteNames.collection);
    if (mounted) setState(() {});
  }

  Future<void> _openCompanions() async {
    await Navigator.of(context).pushNamed(RouteNames.companions);
    if (mounted) setState(() {});
  }

  Future<void> _openRoom() async {
    await Navigator.of(context).pushNamed(RouteNames.room);
    if (mounted) setState(() {});
  }

  Future<void> _openParentGate() async {
    await Navigator.of(context).pushNamed(RouteNames.parentGate);
    if (mounted) setState(() {});
  }

  Future<void> _openCustomize() async {
    await Navigator.of(context).pushNamed(RouteNames.heroSelection);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final storage = AppScope.of(context).storage;
    final profile = HeroRepository(storage).load();
    final stars = ProgressRepository(storage).stars;
    final coins = CoinRepository(storage).coins;
    final badgeCount = BadgeCatalog.earnedBadgeIds(
      BadgeStats(
        completedQuestIds: QuestRepository(storage).completedQuestIds(),
        miniGameStarIds: MiniGameRepository(storage).starEarnedGameIds(),
        totalStars: stars,
        totalCoins: coins,
      ),
    ).length;
    final selectedCompanionId = CompanionRepository(storage).selectedCompanionId;
    Companion? activeCompanion;
    for (final companion in CompanionCatalog.all) {
      if (companion.id == selectedCompanionId) {
        activeCompanion = companion;
        break;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    key: const ValueKey('parent_zone_entry'),
                    onPressed: _openParentGate,
                    icon: const Icon(Icons.shield_outlined),
                    color: Colors.grey.shade500,
                    tooltip: 'For grown-ups',
                  ),
                  Row(
                    children: [
                      _CurrencyBadge(
                        icon: Icons.star_rounded,
                        color: AppColors.star,
                        value: stars,
                      ),
                      const SizedBox(width: 10),
                      _CurrencyBadge(
                        icon: Icons.monetization_on_rounded,
                        color: AppColors.coin,
                        value: coins,
                      ),
                      const SizedBox(width: 10),
                      _CurrencyBadge(
                        icon: Icons.emoji_events_rounded,
                        color: AppColors.grapePurple,
                        value: badgeCount,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  HeroAvatarPreview(profile: profile, size: 200),
                  if (activeCompanion != null)
                    Positioned(
                      bottom: 0,
                      right: -8,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: activeCompanion.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Icon(
                          activeCompanion.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Ready for adventure?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              BigRoundedButton(
                label: 'Adventure Map',
                icon: Icons.map_rounded,
                backgroundColor: AppColors.skyBlue,
                onPressed: _openAdventureMap,
              ),
              const SizedBox(height: 12),
              BigRoundedButton(
                label: 'Mini-Games',
                icon: Icons.videogame_asset_rounded,
                backgroundColor: AppColors.grapePurple,
                onPressed: _openMiniGames,
              ),
              const SizedBox(height: 12),
              BigRoundedButton(
                label: 'My Collection',
                icon: Icons.emoji_events_rounded,
                backgroundColor: AppColors.coral,
                onPressed: _openCollection,
              ),
              const SizedBox(height: 12),
              BigRoundedButton(
                label: 'My Companions',
                icon: Icons.pets_rounded,
                backgroundColor: AppColors.leafGreen,
                onPressed: _openCompanions,
              ),
              const SizedBox(height: 12),
              BigRoundedButton(
                label: 'My Room',
                icon: Icons.chair_rounded,
                backgroundColor: AppColors.skyBlue,
                onPressed: _openRoom,
              ),
              const SizedBox(height: 12),
              BigRoundedButton(
                label: 'Customize',
                icon: Icons.checkroom_rounded,
                backgroundColor: AppColors.grapePurple,
                onPressed: _openCustomize,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyBadge extends StatelessWidget {
  const _CurrencyBadge({
    required this.icon,
    required this.color,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.inkNavy),
          ),
        ],
      ),
    );
  }
}
