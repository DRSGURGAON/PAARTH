import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../game/repositories/hero_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../player/hero_avatar_preview.dart';

/// Landing spot after the hero is created: shows the hero, current
/// stars, and the single next action — head to the Adventure Map.
/// Stateful so the star badge refreshes when the child comes back from
/// an adventure with new stars.
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

  @override
  Widget build(BuildContext context) {
    final storage = AppScope.of(context).storage;
    final profile = HeroRepository(storage).load();
    final stars = ProgressRepository(storage).stars;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _StarBadge(stars: stars),
              ),
              const Spacer(),
              HeroAvatarPreview(profile: profile, size: 200),
              const SizedBox(height: 16),
              Text(
                'Ready for adventure?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarBadge extends StatelessWidget {
  const _StarBadge({required this.stars});

  final int stars;

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
          const Icon(Icons.star_rounded, color: AppColors.star),
          const SizedBox(width: 6),
          Text(
            '$stars',
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
