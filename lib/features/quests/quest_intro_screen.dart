import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../game/models/quest.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../../shared/widgets/pop_in.dart';
import 'quest_play_screen.dart';
import 'story_dialogue.dart';

/// Sets up the quest's story problem before any challenge appears, so
/// the child knows *why* they're solving things (brief section 8): the
/// NPC speaks their short dialogue lines one at a time, then the big
/// START ADVENTURE button appears.
class QuestIntroScreen extends StatefulWidget {
  const QuestIntroScreen({required this.quest, super.key});

  final Quest quest;

  @override
  State<QuestIntroScreen> createState() => _QuestIntroScreenState();
}

class _QuestIntroScreenState extends State<QuestIntroScreen> {
  bool _dialogueFinished = false;

  void _startAdventure() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => QuestPlayScreen(quest: widget.quest),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quest = widget.quest;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                quest.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Spacer(),
              if (!_dialogueFinished)
                StoryDialogue(
                  npc: quest.npc,
                  lines: quest.effectiveIntroDialogue,
                  onFinished: () => setState(() => _dialogueFinished = true),
                )
              else ...[
                PopIn(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: quest.npc == null
                        ? const Icon(Icons.rocket_launch_rounded,
                            size: 56, color: Colors.white)
                        : Text(quest.npc!.emoji,
                            style: const TextStyle(fontSize: 56)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Ready, Super Kid?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
              const Spacer(),
              if (_dialogueFinished)
                BigRoundedButton(
                  label: 'Start Adventure',
                  icon: Icons.rocket_launch_rounded,
                  backgroundColor: AppColors.coral,
                  onPressed: _startAdventure,
                ),
              const SizedBox(height: 4),
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
