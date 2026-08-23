import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/audio/feedback_service.dart';
import '../../core/audio/sound_event.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/companion_catalog.dart';
import '../../game/models/memory_round.dart';
import '../../game/models/quest.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/companion_repository.dart';
import '../../game/repositories/mini_game_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/systems/difficulty_tracker.dart';
import '../../game/systems/memory_round_generator.dart';
import '../../game/systems/quest_engine.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../../shared/widgets/pop_in.dart';
import '../../shared/widgets/shake_widget.dart';

/// Memory Master: show a set of objects, hide them, then ask what was
/// remembered (position / sequence / object / number — brief section
/// 9B). 5 rounds; first-try scoring; predictable reward stated up front.
class MemoryMasterScreen extends StatefulWidget {
  const MemoryMasterScreen({this.random, super.key});

  final Random? random;

  static const int roundLength = 5;
  static const int starThreshold = 4;
  static const int coinReward = 5;

  @override
  State<MemoryMasterScreen> createState() => MemoryMasterScreenState();
}

enum _RoundPhase { intro, studying, answering, results }

@visibleForTesting
class MemoryMasterScreenState extends State<MemoryMasterScreen> {
  late MemoryRoundGenerator _generator;
  late DifficultyTracker _tracker;
  late ProgressRepository _progressRepository;
  late CoinRepository _coinRepository;
  late MiniGameRepository _miniGameRepository;
  late FeedbackService _feedbackService;
  late bool _pandaActive;
  bool _loaded = false;

  _RoundPhase _phase = _RoundPhase.intro;
  late MemoryRound _round;
  late Duration _studyDuration;
  int _roundNumber = 0;
  int _score = 0;
  bool _firstAttempt = true;
  bool _starEarned = false;
  String? _feedback;
  int _shakeSignal = 0;

  @visibleForTesting
  MemoryRound get currentRound => _round;

  /// The study time actually used this round — 1.5x the round's base
  /// duration when Panda (the Memory Master companion) is equipped.
  @visibleForTesting
  Duration get currentStudyDuration => _studyDuration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _generator = MemoryRoundGenerator(random: widget.random);
    _tracker = DifficultyTracker(storage);
    _progressRepository = ProgressRepository(storage);
    _coinRepository = CoinRepository(storage);
    _miniGameRepository = MiniGameRepository(storage);
    _feedbackService = FeedbackService(storage);
    _pandaActive =
        CompanionRepository(storage).selectedCompanionId == CompanionIds.panda;
    _loaded = true;
  }

  void _startGame() {
    setState(() {
      _roundNumber = 0;
      _score = 0;
      _starEarned = false;
      _feedback = null;
      _startRound();
    });
  }

  void _startRound() {
    _round = _generator.next(_tracker.levelFor(ChallengeCategory.memory));
    _firstAttempt = true;
    _phase = _RoundPhase.studying;
    _studyDuration = _pandaActive
        ? Duration(
            microseconds: (_round.studyDuration.inMicroseconds * 3) ~/ 2,
          )
        : _round.studyDuration;
    Future.delayed(_studyDuration, () {
      if (!mounted || _phase != _RoundPhase.studying) return;
      setState(() => _phase = _RoundPhase.answering);
    });
  }

  Future<void> _submit(int optionIndex) async {
    final correct = _round.question.isCorrect(optionIndex);

    if (_firstAttempt) {
      await _tracker.recordResult(ChallengeCategory.memory, correct: correct);
      if (correct) _score++;
    }
    if (!mounted) return;

    if (!correct) {
      _feedbackService.play(SoundEvent.incorrect);
      setState(() {
        _firstAttempt = false;
        _feedback = QuestEngine
            .encouragements[_roundNumber % QuestEngine.encouragements.length];
        _shakeSignal++;
      });
      return;
    }

    if (_roundNumber + 1 >= MemoryMasterScreen.roundLength) {
      if (_score >= MemoryMasterScreen.starThreshold) {
        await _progressRepository.addStars(1);
        await _coinRepository.addCoins(MemoryMasterScreen.coinReward);
        await _miniGameRepository.markStarEarned(MiniGameIds.memoryMaster);
        _starEarned = true;
      }
      if (!mounted) return;
      _feedbackService
          .play(_starEarned ? SoundEvent.reward : SoundEvent.correct);
      setState(() => _phase = _RoundPhase.results);
      return;
    }

    _feedbackService.play(SoundEvent.correct);
    setState(() {
      _roundNumber++;
      _feedback = null;
      _startRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Master')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_phase) {
            _RoundPhase.intro => _IntroView(onStart: _startGame),
            _RoundPhase.studying => _buildStudying(context),
            _RoundPhase.answering => _buildAnswering(context),
            _RoundPhase.results => _ResultsView(
                score: _score,
                starEarned: _starEarned,
                onPlayAgain: _startGame,
                onDone: () => Navigator.of(context).pop(),
              ),
          },
        ),
      ),
    );
  }

  Widget _buildStudying(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          'Round ${_roundNumber + 1} of ${MemoryMasterScreen.roundLength}',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge,
        ),
        const Spacer(),
        Text(
          'Remember these!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        if (_pandaActive) ...[
          const SizedBox(height: 8),
          Text(
            'Panda is giving you extra time! 🐼',
            key: const ValueKey('panda_hint_label'),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.coral),
          ),
        ],
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final item in _round.items)
              Text(item, style: const TextStyle(fontSize: 48)),
          ],
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildAnswering(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final question = _round.question;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Round ${_roundNumber + 1} of ${MemoryMasterScreen.roundLength}',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge,
        ),
        const Spacer(),
        Text(
          question.prompt,
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
                  style: textTheme.bodyLarge
                      ?.copyWith(color: AppColors.gentleWarning),
                ),
        ),
        const Spacer(),
        ShakeWidget(
          shakeSignal: _shakeSignal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < question.options.length; i++) ...[
                FilledButton(
                  key: ValueKey('option_$i'),
                  onPressed: () => _submit(i),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.inkNavy,
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  child: Text(question.options[i]),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _IntroView extends StatelessWidget {
  const _IntroView({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const Spacer(),
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: AppColors.coral,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.psychology_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Play ${MemoryMasterScreen.roundLength} memory rounds!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Watch closely, then answer from memory. '
          'Get ${MemoryMasterScreen.starThreshold} right on the first try '
          'to earn a ⭐',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        const Spacer(flex: 2),
        BigRoundedButton(
          label: "Let's Go!",
          icon: Icons.play_arrow_rounded,
          backgroundColor: AppColors.skyBlue,
          onPressed: onStart,
        ),
      ],
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    required this.score,
    required this.starEarned,
    required this.onPlayAgain,
    required this.onDone,
  });

  final int score;
  final bool starEarned;
  final VoidCallback onPlayAgain;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const Spacer(),
        PopIn(
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.sunshineYellow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              starEarned
                  ? Icons.emoji_events_rounded
                  : Icons.sentiment_satisfied_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'You got $score of ${MemoryMasterScreen.roundLength}!',
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          starEarned
              ? 'Amazing! You earned +1 ⭐  +${MemoryMasterScreen.coinReward} 🪙'
              : 'Great effort! Try again to earn a ⭐',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        const Spacer(flex: 2),
        BigRoundedButton(
          label: 'Play Again',
          icon: Icons.replay_rounded,
          backgroundColor: AppColors.coral,
          onPressed: onPlayAgain,
        ),
        const SizedBox(height: 12),
        BigRoundedButton(
          label: 'Done',
          icon: Icons.check_rounded,
          backgroundColor: AppColors.leafGreen,
          onPressed: onDone,
        ),
      ],
    );
  }
}
