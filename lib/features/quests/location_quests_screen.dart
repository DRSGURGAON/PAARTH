import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/models/quest.dart';
import '../../game/models/world_location.dart';
import '../../game/quests/jungle_quests.dart';
import '../../game/repositories/quest_repository.dart';
import 'quest_intro_screen.dart';

/// The quests available at one map location. Completed quests stay
/// replayable for practice (marked with a check, no repeat rewards).
class LocationQuestsScreen extends StatefulWidget {
  const LocationQuestsScreen({required this.location, super.key});

  final WorldLocation location;

  @override
  State<LocationQuestsScreen> createState() => _LocationQuestsScreenState();
}

class _LocationQuestsScreenState extends State<LocationQuestsScreen> {
  Future<void> _openQuest(Quest quest) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuestIntroScreen(quest: quest),
      ),
    );
    // Refresh completion checkmarks after the child returns.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final quests = JungleQuests.forLocation(widget.location.id);
    final completedIds =
        QuestRepository(AppScope.of(context).storage).completedQuestIds();

    return Scaffold(
      appBar: AppBar(title: Text(widget.location.name)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: quests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final quest = quests[index];
            final isCompleted = completedIds.contains(quest.id);
            return _QuestCard(
              quest: quest,
              isCompleted: isCompleted,
              onTap: () => _openQuest(quest),
            );
          },
        ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.quest,
    required this.isCompleted,
    required this.onTap,
  });

  final Quest quest;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.leafGreen
                      : AppColors.sunshineYellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? 'Completed! Play again for practice'
                          : 'Earn ${quest.starReward} ⭐',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
