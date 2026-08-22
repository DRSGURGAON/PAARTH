import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/models/quest.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/systems/difficulty_tracker.dart';
import '../../game/systems/math_question_generator.dart';
import '../../game/systems/quest_engine.dart';
import '../../shared/widgets/big_rounded_button.dart';

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

  @override
  State<MathDashScreen> createState() => MathDashScreenState();
}

enum _DashPhase { intro, playing, results }

@visibleForTesting
class MathDashScreenState extends State<MathDashScreen> {
  late MathQuestionGenerator _generator;
  late DifficultyTracker _tracker;
  late ProgressRepository _progressRepository;
  bool _loaded = false;

  _DashPhase _phase = _DashPhase.intro;
  late ChoiceChallenge _challenge;
  int _questionNumber = 0;
  int _score = 0;
  bool _firstAttempt = true;
  bool _starEarned = false;
  String? _feedback;

  @visibleForTesting
  ChoiceChallenge get currentChallenge => _challenge;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _generator = MathQuestionGenerator(random: widget.random);
    _tracker = DifficultyTracker(storage);
    _progressRepository = ProgressRepository(storage);
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
  }

  Future<void> _submit(int optionIndex) async {
    final correct = _challenge.isCorrect(optionIndex);

    if (_firstAttempt) {
      await _tracker.recordResult(ChallengeCategory.math, correct: correct);
      if (correct) _score++;
    }
    if (!mounted) return;

    if (!correct) {
      setState(() {
        _firstAttempt = false;
        _feedback = QuestEngine
            .encouragements[_questionNumber % QuestEngine.encouragements.length];
      });
      return;
    }

    if (_questionNumber + 1 >= MathDashScreen.roundLength) {
      if (_score >= MathDashScreen.starThreshold) {
        await _progressRepository.addStars(1);
        _starEarned = true;
      }
      if (!mounted) return;
      setState(() => _phase = _DashPhase.results);
      return;
    }

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
        const Spacer(),
        for (var i = 0; i < _challenge.options.length; i++) ...[
          FilledButton(
            key: ValueKey('option_$i'),
            onPressed: () => _submit(i),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.inkNavy,
            ),
            child: Text(_challenge.options[i]),
          ),
          const SizedBox(height: 12),
        ],
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
        Container(
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
        const SizedBox(height: 24),
        Text(
          'You got $score of ${MathDashScreen.roundLength}!',
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          starEarned
              ? 'Amazing! You earned +1 ⭐'
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
