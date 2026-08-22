import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../game/models/quest.dart';
import '../../shared/widgets/big_rounded_button.dart';
import 'quest_play_screen.dart';

/// Sets up the quest's story problem before any challenge appears, so
/// the child knows *why* they're solving things (brief section 8).
class QuestIntroScreen extends StatelessWidget {
  const QuestIntroScreen({required this.quest, super.key});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.grapePurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                quest.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Text(
                quest.storyIntro,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(flex: 2),
              BigRoundedButton(
                label: 'Start Quest',
                icon: Icons.rocket_launch_rounded,
                backgroundColor: AppColors.coral,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => QuestPlayScreen(quest: quest),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Maybe later'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
