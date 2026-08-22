import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/models/quest.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/mini_game_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/systems/difficulty_tracker.dart';
import '../../game/systems/pattern_question_generator.dart';
import '../../game/systems/quest_engine.dart';
import '../../shared/widgets/big_rounded_button.dart';

/// Pattern Power: a round of 8 generated pattern-completion puzzles.
/// Same round shape as Math Dash (first-try scoring, gentle retry,
/// predictable reward) — see that screen's doc comment for the reasoning
/// on why this isn't factored into a shared base class yet.
class PatternPowerScreen extends StatefulWidget {
  const PatternPowerScreen({this.random, super.key});

  final Random? random;

  static const int roundLength = 8;
  static const int starThreshold = 6;
  static const int coinReward = 5;

  @override
  State<PatternPowerScreen> createState() => PatternPowerScreenState();
}

enum _RoundPhase { intro, playing, results }

@visibleForTesting
class PatternPowerScreenState extends State<PatternPowerScreen> {
  late PatternQuestionGenerator _generator;
  late DifficultyTracker _tracker;
  late ProgressRepository _progressRepository;
  late CoinRepository _coinRepository;
  late MiniGameRepository _miniGameRepository;
  bool _loaded = false;

  _RoundPhase _phase = _RoundPhase.intro;
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
    _generator = PatternQuestionGenerator(random: widget.random);
    _tracker = DifficultyTracker(storage);
    _progressRepository = ProgressRepository(storage);
    _coinRepository = CoinRepository(storage);
    _miniGameRepository = MiniGameRepository(storage);
    _loaded = true;
  }

  void _startRound() {
    setState(() {
      _phase = _RoundPhase.playing;
      _questionNumber = 0;
      _score = 0;
      _starEarned = false;
      _feedback = null;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    _challenge = _generator.next(_tracker.levelFor(ChallengeCategory.logic));
    _firstAttempt = true;
  }

  Future<void> _submit(int optionIndex) async {
    final correct = _challenge.isCorrect(optionIndex);

    if (_firstAttempt) {
      await _tracker.recordResult(ChallengeCategory.logic, correct: correct);
      if (correct) _score++;
    }
    if (!mounted) return;

    if (!correct) {
      setState(() {
        _firstAttempt = false;
        _feedback = QuestEngine.encouragements[
            _questionNumber % QuestEngine.encouragements.length];
      });
      return;
    }

    if (_questionNumber + 1 >= PatternPowerScreen.roundLength) {
      if (_score >= PatternPowerScreen.starThreshold) {
        await _progressRepository.addStars(1);
        await _coinRepository.addCoins(PatternPowerScreen.coinReward);
        await _miniGameRepository.markStarEarned(MiniGameIds.patternPower);
        _starEarned = true;
      }
      if (!mounted) return;
      setState(() => _phase = _RoundPhase.results);
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
      appBar: AppBar(title: const Text('Pattern Power')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_phase) {
            _RoundPhase.intro => _IntroView(onStart: _startRound),
            _RoundPhase.playing => _buildPlaying(context),
            _RoundPhase.results => _ResultsView(
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
          'Question ${_questionNumber + 1} of ${PatternPowerScreen.roundLength}',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge,
        ),
        const Spacer(),
        Text(
          _challenge.visual ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 36, height: 1.4),
        ),
        const SizedBox(height: 16),
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
              textStyle: const TextStyle(fontSize: 28),
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
            color: AppColors.grapePurple,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.pattern_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Spot ${PatternPowerScreen.roundLength} patterns!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Get ${PatternPowerScreen.starThreshold} right on the first try '
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
          'You got $score of ${PatternPowerScreen.roundLength}!',
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          starEarned
              ? 'Amazing! You earned +1 ⭐  +${PatternPowerScreen.coinReward} 🪙'
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
