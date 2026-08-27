import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/models/game_world.dart';
import '../../game/quests/quest_catalog.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/repositories/quest_repository.dart';
import '../../game/worlds/worlds.dart';
import '../../shared/widgets/shake_widget.dart';
import 'adventure_map_screen.dart';

/// The five-world overview the Adventure Map button now opens: one card
/// per world showing locked (with how many more stars are needed),
/// unlocked (with quest progress), or fully completed. Like the map
/// nodes, every state is derived live from stars and completed quest
/// ids — never stored.
class WorldSelectScreen extends StatefulWidget {
  const WorldSelectScreen({super.key});

  @override
  State<WorldSelectScreen> createState() => _WorldSelectScreenState();
}

class _WorldSelectScreenState extends State<WorldSelectScreen> {
  /// Bumped per-world to trigger the gentle "no" shake on locked cards.
  final List<int> _lockShakeSignals = List.filled(Worlds.all.length, 0);

  Future<void> _openWorld(GameWorld world) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdventureMapScreen(world: world),
      ),
    );
    // Stars may have been earned inside — refresh locks and progress.
    if (mounted) setState(() {});
  }

  void _showLockedHint(GameWorld world, int stars, int index) {
    setState(() => _lockShakeSignals[index]++);
    final remaining = world.requiredStars - stars;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Earn $remaining more ⭐ to unlock ${world.name}!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = AppScope.of(context).storage;
    final stars = ProgressRepository(storage).stars;
    final completedQuestIds = QuestRepository(storage).completedQuestIds();

    return Scaffold(
      appBar: AppBar(title: const Text('Adventure Worlds')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cream, Color(0xFFE3EDF9)],
          ),
        ),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: Worlds.all.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final world = Worlds.all[index];
              final isUnlocked = world.isUnlockedFor(stars);
              final worldQuests = world.locations
                  .expand((l) => QuestCatalog.forLocation(l.id))
                  .toList();
              final completedCount = worldQuests
                  .where((q) => completedQuestIds.contains(q.id))
                  .length;
              return ShakeWidget(
                shakeSignal: _lockShakeSignals[index],
                child: _WorldCard(
                  key: ValueKey('world_${world.id}'),
                  world: world,
                  isUnlocked: isUnlocked,
                  stars: stars,
                  completedCount: completedCount,
                  totalCount: worldQuests.length,
                  onTap: () {
                    if (isUnlocked) {
                      _openWorld(world);
                    } else {
                      _showLockedHint(world, stars, index);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  const _WorldCard({
    required this.world,
    required this.isUnlocked,
    required this.stars,
    required this.completedCount,
    required this.totalCount,
    required this.onTap,
    super.key,
  });

  final GameWorld world;
  final bool isUnlocked;
  final int stars;
  final int completedCount;
  final int totalCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = totalCount > 0 && completedCount >= totalCount;
    final subtitle = !isUnlocked
        ? '${world.requiredStars - stars} more ⭐ to unlock'
        : isCompleted
            ? 'World complete! Play again anytime'
            : '$completedCount / $totalCount quests done';

    final semanticLabel = !isUnlocked
        ? '${world.name}, locked. Earn ${world.requiredStars} stars total '
            'to unlock.'
        : '${world.name}. $subtitle. Tap to explore.';

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: !isUnlocked
                        ? Colors.grey.shade300
                        : isCompleted
                            ? AppColors.sunshineYellow
                            : AppColors.leafGreen,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: !isUnlocked
                      ? Icon(Icons.lock_rounded,
                          color: Colors.grey.shade600, size: 32)
                      : Text(
                          world.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        world.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: !isUnlocked
                                  ? Colors.grey.shade600
                                  : AppColors.inkNavy,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUnlocked ? world.tagline : subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (isUnlocked) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: isCompleted
                                        ? AppColors.leafGreen
                                        : AppColors.inkNavy
                                            .withValues(alpha: 0.7),
                                    fontWeight: isCompleted
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.leafGreen, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
