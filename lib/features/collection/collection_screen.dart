import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/badge_catalog.dart';
import '../../game/models/badge.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/mini_game_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/repositories/quest_repository.dart';

/// The "🎒 Collection" screen (design brief section 11): every badge in
/// the game, earned ones bright and described, locked ones greyed with
/// a lock. Earned status is always recomputed live from real progress —
/// there is no separate "badge earned" flag to fall out of sync.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = AppScope.of(context).storage;
    final stats = BadgeStats(
      completedQuestIds: QuestRepository(storage).completedQuestIds(),
      miniGameStarIds: MiniGameRepository(storage).starEarnedGameIds(),
      totalStars: ProgressRepository(storage).stars,
      totalCoins: CoinRepository(storage).coins,
    );
    final earnedIds = BadgeCatalog.earnedBadgeIds(stats);
    final badges = BadgeCatalog.all;

    return Scaffold(
      appBar: AppBar(title: const Text('My Collection')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                '${earnedIds.length} of ${badges.length} badges earned',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  final earned = earnedIds.contains(badge.id);
                  return _BadgeCard(badge: badge, earned: earned);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge, required this.earned});

  final GameBadge badge;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: earned ? Colors.white : const Color(0xFFF0F0F0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: earned ? AppColors.sunshineYellow : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Icon(
                earned ? badge.icon : Icons.lock_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 16,
                color: earned ? AppColors.inkNavy : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
