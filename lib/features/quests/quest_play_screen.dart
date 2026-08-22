import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/models/quest.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/repositories/quest_repository.dart';
import '../../game/systems/quest_engine.dart';
import 'quest_complete_screen.dart';

/// Plays a quest's challenges one at a time: big visual, short prompt,
/// large answer buttons. Wrong answers get rotating encouragement and a
/// retry; each solved challenge hands over its story item; solving the
/// last one goes straight to the celebration screen.
class QuestPlayScreen extends StatefulWidget {
  const QuestPlayScreen({required this.quest, super.key});

  final Quest quest;

  @override
  State<QuestPlayScreen> createState() => _QuestPlayScreenState();
}

class _QuestPlayScreenState extends State<QuestPlayScreen> {
  late QuestEngine _engine;
  bool _loaded = false;
  String? _feedback;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Same guard pattern as HeroSelectionScreen: AppScope needs the
    // tree, and a repeat didChangeDependencies must not reset a quest
    // the child is halfway through.
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _engine = QuestEngine(
      quest: widget.quest,
      progressRepository: ProgressRepository(storage),
      questRepository: QuestRepository(storage),
    );
    _loaded = true;
  }

  Future<void> _submit(int optionIndex) async {
    final challenge = _engine.currentChallenge;
    final result = await _engine.submitAnswer(optionIndex);
    if (!mounted) return;

    switch (result) {
      case AnswerResult.incorrect:
        setState(() => _feedback = _engine.nextEncouragement());
      case AnswerResult.advanced:
        setState(() => _feedback = null);
        if (challenge.rewardLabel != null) {
          await _showRewardDialog(challenge.rewardLabel!);
        }
        if (mounted) setState(() {});
      case AnswerResult.completed:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => QuestCompleteScreen(
              quest: widget.quest,
              starsAwarded: _engine.starsAwarded,
            ),
          ),
        );
    }
  }

  Future<void> _showRewardDialog(String rewardLabel) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.card_giftcard_rounded,
              size: 64,
              color: AppColors.coral,
            ),
            const SizedBox(height: 12),
            Text(
              'You earned:\n$rewardLabel!',
              textAlign: TextAlign.center,
              style: Theme.of(dialogContext).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Next!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _engine.currentChallenge;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.quest.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProgressDots(
                total: widget.quest.challenges.length,
                current: _engine.currentIndex,
              ),
              const Spacer(),
              if (challenge.visual != null) ...[
                Text(
                  challenge.visual!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 40, height: 1.4),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                challenge.prompt,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 32,
                child: _feedback == null
                    ? null
                    : Text(
                        _feedback!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.gentleWarning,
                        ),
                      ),
              ),
              const Spacer(),
              for (var i = 0; i < challenge.options.length; i++) ...[
                FilledButton(
                  key: ValueKey('option_$i'),
                  onPressed: () => _submit(i),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.inkNavy,
                  ),
                  child: Text(challenge.options[i]),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: i < current
                  ? AppColors.leafGreen
                  : i == current
                      ? AppColors.sunshineYellow
                      : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
