import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/audio/feedback_service.dart';
import '../../core/audio/sound_event.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/companion_catalog.dart';
import '../../game/models/quest.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/companion_repository.dart';
import '../../game/repositories/mini_game_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/systems/difficulty_tracker.dart';
import '../../game/systems/math_question_generator.dart';
import '../../game/systems/quest_engine.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../../shared/widgets/pop_in.dart';
import '../../shared/widgets/shake_widget.dart';

/// Math Dash: a round of 8 generated math puzzles. The reward is stated
/// up front and predictable (6+ first-try correct = 1 star). Wrong
/// answers get the same gentle encouragement as quests and a retry —
/// only the first try counts toward the score and difficulty tracking.
class MathDashScreen extends StatefulWidget {
  const MathDashScreen({this.random, super.key});

  /// Injectable randomness so tests can run deterministic rounds.
  final Random? random;

  static const int roundLength = 8;
  static const int starThreshold = 6;
  static const int coinReward = 5;

  @override
  State<MathDashScreen> createState() => MathDashScreenState();
}

enum _DashPhase { intro, playing, results }

@visibleForTesting
class MathDashScreenState extends State<MathDashScreen> {
  late MathQuestionGenerator _generator;
  late DifficultyTracker _tracker;
  late ProgressRepository _progressRepository;
  late CoinRepository _coinRepository;
  late MiniGameRepository _miniGameRepository;
  late FeedbackService _feedbackService;
  late bool _robotActive;
  bool _loaded = false;

  _DashPhase _phase = _DashPhase.intro;
  late ChoiceChallenge _challenge;
  int _questionNumber = 0;
  int _score = 0;
  bool _firstAttempt = true;
  bool _starEarned = false;
  String? _feedback;
  bool _hintUsed = false;
  int _shakeSignal = 0;
  final Set<int> _eliminatedOptions = {};

  @visibleForTesting
  ChoiceChallenge get currentChallenge => _challenge;

  /// Whether Robot (the Math Dash companion) is equipped, i.e. the hint
  /// button should be offered at all this round.
  @visibleForTesting
  bool get hintAvailable => _robotActive;

  @visibleForTesting
  Set<int> get eliminatedOptions => _eliminatedOptions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _generator = MathQuestionGenerator(random: widget.random);
    _tracker = DifficultyTracker(storage);
    _progressRepository = ProgressRepository(storage);
    _coinRepository = CoinRepository(storage);
    _miniGameRepository = MiniGameRepository(storage);
    _feedbackService = FeedbackService(storage);
    _robotActive =
        CompanionRepository(storage).selectedCompanionId == CompanionIds.robot;
    _loaded = true;
  }

  void _startRound() {
    setState(() {
      _phase = _DashPhase.playing;
      _questionNumber = 0;
      _score = 0;
      _starEarned = false;
      _feedback = null;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    _challenge =
        _generator.next(_tracker.levelFor(ChallengeCategory.math));
    _firstAttempt = true;
    _hintUsed = false;
    _eliminatedOptions.clear();
  }

  /// Robot's hint: crosses out the first wrong-and-not-yet-eliminated
  /// option, once per question. Never touches the correct index, so the
  /// child still has to pick it themselves.
  void _useHint() {
    if (_hintUsed) return;
    for (var i = 0; i < _challenge.options.length; i++) {
      if (i == _challenge.correctIndex || _eliminatedOptions.contains(i)) {
        continue;
      }
      setState(() {
        _eliminatedOptions.add(i);
        _hintUsed = true;
      });
      return;
    }
  }

  Future<void> _submit(int optionIndex) async {
    final correct = _challenge.isCorrect(optionIndex);

    if (_firstAttempt) {
      await _tracker.recordResult(ChallengeCategory.math, correct: correct);
      if (correct) _score++;
    }
    if (!mounted) return;

    if (!correct) {
      _feedbackService.play(SoundEvent.incorrect);
      setState(() {
        _firstAttempt = false;
        _feedback = QuestEngine
            .encouragements[_questionNumber % QuestEngine.encouragements.length];
        _shakeSignal++;
      });
      return;
    }

    if (_questionNumber + 1 >= MathDashScreen.roundLength) {
      if (_score >= MathDashScreen.starThreshold) {
        await _progressRepository.addStars(1);
        await _coinRepository.addCoins(MathDashScreen.coinReward);
        await _miniGameRepository.markStarEarned(MiniGameIds.mathDash);
        _starEarned = true;
      }
      if (!mounted) return;
      _feedbackService
          .play(_starEarned ? SoundEvent.reward : SoundEvent.correct);
      setState(() => _phase = _DashPhase.results);
      return;
    }

    _feedbackService.play(SoundEvent.correct);
    setState(() {
      _questionNumber++;
      _feedback = null;
      _nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Math Dash')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_phase) {
            _DashPhase.intro => _IntroView(onStart: _startRound),
            _DashPhase.playing => _buildPlaying(context),
            _DashPhase.results => _ResultsView(
                score: _score,
                starEarned: _starEarned,
                onPlayAgain: _startRound,
                onDone: () => Navigator.of(context).pop(),
              ),
          },
        ),
      ),
    );
  }

  Widget _buildPlaying(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Question ${_questionNumber + 1} of ${MathDashScreen.roundLength}',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge,
        ),
        const Spacer(),
        if (_challenge.visual != null) ...[
          Text(
            _challenge.visual!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 36, height: 1.4),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          _challenge.prompt,
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
        if (_robotActive && !_hintUsed) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey('robot_hint_button'),
              onPressed: _useHint,
              icon: const Icon(Icons.smart_toy_rounded, color: AppColors.skyBlue),
              label: const Text('Robot Hint'),
            ),
          ),
          const SizedBox(height: 4),
        ],
        const Spacer(),
        ShakeWidget(
          shakeSignal: _shakeSignal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _challenge.options.length; i++) ...[
                FilledButton(
                  key: ValueKey('option_$i'),
                  onPressed: _eliminatedOptions.contains(i)
                      ? null
                      : () => _submit(i),
                  style: FilledButton.styleFrom(
                    backgroundColor: _eliminatedOptions.contains(i)
                        ? Colors.grey.shade300
                        : Colors.white,
                    foregroundColor: _eliminatedOptions.contains(i)
                        ? Colors.grey.shade500
                        : AppColors.inkNavy,
                  ),
                  child: Text(
                    _challenge.options[i],
                    style: _eliminatedOptions.contains(i)
                        ? const TextStyle(decoration: TextDecoration.lineThrough)
                        : null,
                  ),
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
            color: AppColors.skyBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.calculate_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Solve ${MathDashScreen.roundLength} number puzzles!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Get ${MathDashScreen.starThreshold} right on the first try '
          'to earn a ⭐',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        const Spacer(flex: 2),
        BigRoundedButton(
          label: "Let's Go!",
          icon: Icons.play_arrow_rounded,
          backgroundColor: AppColors.coral,
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
          'You got $score of ${MathDashScreen.roundLength}!',
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          starEarned
              ? 'Amazing! You earned +1 ⭐  +${MathDashScreen.coinReward} 🪙'
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
