import 'package:flutter/material.dart';

import '../../core/audio/feedback_service.dart';
import '../../core/audio/sound_event.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/models/quest.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/repositories/quest_progress_repository.dart';
import '../../game/models/mini_game_result.dart';
import '../../game/repositories/quest_repository.dart';
import '../../game/systems/quest_engine.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../../shared/widgets/shake_widget.dart';
import '../mini_games/math_dash_screen.dart';
import 'quest_complete_screen.dart';
import 'quest_resolution_screen.dart';

/// Plays a quest's challenges one at a time: big visual, short prompt,
/// large answer buttons. Wrong answers get rotating encouragement (plus
/// the challenge's gentle hint) and a retry; each solved challenge
/// hands over its story item; solving the last one flows into the
/// quest's story resolution, then the celebration screen.
///
/// Memory challenges get a study phase first: the items show big until
/// the child taps "I'm ready!" — no timer, so it can't feel rushed.
class QuestPlayScreen extends StatefulWidget {
  const QuestPlayScreen({required this.quest, super.key});

  final Quest quest;

  @override
  State<QuestPlayScreen> createState() => _QuestPlayScreenState();
}

class _QuestPlayScreenState extends State<QuestPlayScreen> {
  late QuestEngine _engine;
  late FeedbackService _feedbackService;
  bool _loaded = false;
  String? _feedback;
  String? _hint;
  int _shakeSignal = 0;
  bool _studying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Same guard pattern as HeroSelectionScreen: AppScope needs the
    // tree, and a repeat didChangeDependencies must not reset a quest
    // the child is halfway through. (The engine itself also restores a
    // saved run of this quest, so even a full app restart resumes at
    // the start of the current challenge.)
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _engine = QuestEngine(
      quest: widget.quest,
      progressRepository: ProgressRepository(storage),
      questRepository: QuestRepository(storage),
      coinRepository: CoinRepository(storage),
      questProgressRepository: QuestProgressRepository(storage),
    );
    _feedbackService = FeedbackService(storage);
    _studying = !_engine.isComplete && _engine.currentChallenge is MemoryChallenge;
    _loaded = true;
  }

  Future<void> _submit(int optionIndex) async {
    final challenge = _engine.currentChallenge;
    final result = await _engine.submitAnswer(optionIndex);
    if (!mounted) return;

    switch (result) {
      case AnswerResult.incorrect:
        _feedbackService.play(SoundEvent.incorrect);
        setState(() {
          _feedback = _engine.nextEncouragement();
          _hint = challenge.hint;
          _shakeSignal++;
        });
      case AnswerResult.advanced:
        _feedbackService.play(SoundEvent.correct);
        setState(() {
          _feedback = null;
          _hint = null;
        });
        if (challenge.rewardLabel != null) {
          await _showRewardDialog(challenge.rewardLabel!);
        }
        if (mounted) {
          setState(() {
            _studying = _engine.currentChallenge is MemoryChallenge;
          });
        }
      case AnswerResult.completed:
        _feedbackService.play(SoundEvent.correct);
        if (challenge.rewardLabel != null) {
          await _showRewardDialog(challenge.rewardLabel!);
        }
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => widget.quest.resolutionSteps.isEmpty
                ? QuestCompleteScreen(
                    quest: widget.quest,
                    starsAwarded: _engine.starsAwarded,
                    coinsAwarded: _engine.coinsAwarded,
                  )
                : QuestResolutionScreen(
                    quest: widget.quest,
                    starsAwarded: _engine.starsAwarded,
                    coinsAwarded: _engine.coinsAwarded,
                  ),
          ),
        );
    }
  }

  /// Runs an embedded Math Dash session for [challenge]; a completed
  /// session counts as this challenge's correct answer. Backing out
  /// mid-session leaves the challenge current — nothing is lost.
  Future<void> _launchMathDash(MathDashChallenge challenge) async {
    final result = await Navigator.of(context).push<MathDashResult>(
      MaterialPageRoute<MathDashResult>(
        builder: (_) => MathDashScreen(
          embedded: true,
          sessionLength: challenge.questionCount,
        ),
      ),
    );
    if (!mounted) return;
    if (result != null && result.completed) {
      await _submit(challenge.correctIndex);
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
    // After the final correct answer the reward dialog shows while this
    // screen is still behind it — the engine is complete by then, so
    // keep rendering the last challenge instead of indexing past it.
    final challenge = _engine.isComplete
        ? widget.quest.challenges.last
        : _engine.currentChallenge;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.quest.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: challenge is MathDashChallenge
              ? _MathDashLauncher(
                  challenge: challenge,
                  progress: _ProgressDots(
                    total: widget.quest.challenges.length,
                    current: _engine.currentIndex,
                  ),
                  onPlay: () => _launchMathDash(challenge),
                )
              : _studying && challenge is MemoryChallenge
              ? _StudyPhase(
                  challenge: challenge,
                  onReady: () => setState(() => _studying = false),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProgressDots(
                      total: widget.quest.challenges.length,
                      current: _engine.currentIndex,
                    ),
                    const Spacer(),
                    if (challenge is ChoiceChallenge &&
                        challenge.visual != null) ...[
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
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 56,
                      child: _feedback == null
                          ? null
                          : Column(
                              children: [
                                Text(
                                  _feedback!,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: AppColors.gentleWarning,
                                  ),
                                ),
                                if (_hint != null)
                                  Text(
                                    '💡 $_hint',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium,
                                  ),
                              ],
                            ),
                    ),
                    const Spacer(),
                    ShakeWidget(
                      shakeSignal: _shakeSignal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                  ],
                ),
        ),
      ),
    );
  }
}

/// Story framing plus one big button for a quest-embedded Math Dash
/// session — the child plays the real mini-game, not a copy of it.
class _MathDashLauncher extends StatelessWidget {
  const _MathDashLauncher({
    required this.challenge,
    required this.progress,
    required this.onPlay,
  });

  final MathDashChallenge challenge;
  final Widget progress;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        progress,
        const Spacer(),
        const Text('🔢', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(
          challenge.prompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Spacer(),
        BigRoundedButton(
          key: const ValueKey('play_math_dash'),
          label: 'Play Math Dash!',
          icon: Icons.calculate_rounded,
          backgroundColor: AppColors.skyBlue,
          onPressed: onPlay,
        ),
      ],
    );
  }
}

/// A memory challenge's look-first phase: the items big and centered,
/// ended only by the child's own "I'm ready!" tap.
class _StudyPhase extends StatelessWidget {
  const _StudyPhase({required this.challenge, required this.onReady});

  final MemoryChallenge challenge;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Text(
          challenge.studyPrompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        Text(
          challenge.itemsToRemember,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 48, height: 1.4),
        ),
        const Spacer(),
        FilledButton(
          key: const ValueKey('memory_ready'),
          onPressed: onReady,
          child: const Text("I'm ready!"),
        ),
      ],
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
