import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/audio/feedback_service.dart';
import '../../core/audio/sound_event.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/companion_catalog.dart';
import '../../game/models/hero_profile.dart';
import '../../game/models/math_question.dart';
import '../../game/models/mini_game_result.dart';
import '../../game/models/quest.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/companion_repository.dart';
import '../../game/repositories/hero_repository.dart';
import '../../game/repositories/mini_game_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/systems/difficulty_tracker.dart';
import '../../game/systems/math_hint_service.dart';
import '../../game/systems/math_question_generator.dart';
import '../../game/systems/quest_engine.dart';
import '../../game/systems/quest_reward_service.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../../shared/widgets/pop_in.dart';
import '../../shared/widgets/shake_widget.dart';
import '../player/hero_avatar_preview.dart';

/// Math Dash — "Solve it. Collect it. Keep moving!" A session of
/// generated math puzzles played with the hero on screen: countable
/// objects instead of bare digits wherever the numbers are small, a
/// gentle hint after every miss, and a positive streak counter. No
/// timers, no penalties — a wrong answer costs nothing but the streak.
///
/// Two ways to play (brief: adventure integration):
/// - **Standalone** (from Mini-Games): [sessionLength] questions,
///   rewards decided by [QuestRewardService.calculateMathDash] and paid
///   out here.
/// - **Embedded in a quest** ([embedded] true, launched by
///   `QuestPlayScreen` for a [MathDashChallenge]): on completion the
///   screen pops with a [MathDashResult] instead of showing results —
///   the quest's own rewards cover the payout, so nothing double-pays.
class MathDashScreen extends StatefulWidget {
  const MathDashScreen({
    this.random,
    this.sessionLength = defaultSessionLength,
    this.embedded = false,
    super.key,
  });

  /// Injectable randomness so tests can run deterministic rounds.
  final Random? random;

  /// Questions per session (brief section 11: short 5-challenge runs).
  final int sessionLength;

  /// True when a quest launched this session as one of its challenges.
  final bool embedded;

  static const int defaultSessionLength = 5;

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
  late HeroProfile _heroProfile;
  late bool _robotActive;
  bool _loaded = false;

  _DashPhase _phase = _DashPhase.intro;
  late MathQuestion _question;
  int _questionNumber = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _level = 1;
  bool _firstAttempt = true;
  MiniGameReward? _reward;
  String? _feedback;
  MathHint? _hint;
  bool _companionHintUsed = false;
  int _shakeSignal = 0;
  final Set<int> _eliminatedOptions = {};

  @visibleForTesting
  MathQuestion get currentQuestion => _question;

  /// Whether Robot (the Math Dash companion) is equipped, i.e. the
  /// cross-out-an-option button should be offered at all this round.
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
    _heroProfile = HeroRepository(storage).load();
    _robotActive =
        CompanionRepository(storage).selectedCompanionId == CompanionIds.robot;
    _loaded = true;
    // A quest-embedded session skips the intro — the quest screen has
    // already framed the story.
    if (widget.embedded) {
      _resetSession();
      _phase = _DashPhase.playing;
    }
  }

  void _resetSession() {
    _questionNumber = 0;
    _score = 0;
    _streak = 0;
    _bestStreak = 0;
    _reward = null;
    _feedback = null;
    _hint = null;
    _nextQuestion();
  }

  void _startRound() {
    setState(() {
      _resetSession();
      _phase = _DashPhase.playing;
    });
  }

  void _nextQuestion() {
    _level = _tracker.levelFor(ChallengeCategory.math);
    _question = _generator.next(_level);
    _firstAttempt = true;
    _companionHintUsed = false;
    _eliminatedOptions.clear();
  }

  /// Robot's help: crosses out the first wrong-and-not-yet-eliminated
  /// option, once per question. Never touches the correct index, so the
  /// child still has to pick it themselves.
  void _useCompanionHint() {
    if (_companionHintUsed) return;
    for (var i = 0; i < _question.options.length; i++) {
      if (i == _question.correctIndex || _eliminatedOptions.contains(i)) {
        continue;
      }
      setState(() {
        _eliminatedOptions.add(i);
        _companionHintUsed = true;
      });
      return;
    }
  }

  Future<void> _finishSession() async {
    if (widget.embedded) {
      // Report back to the quest — its own completion pays the rewards.
      _feedbackService.play(SoundEvent.correct);
      Navigator.of(context).pop(MathDashResult(
        completed: true,
        correctAnswers: _score,
        totalQuestions: widget.sessionLength,
        bestStreak: _bestStreak,
        starsAwarded: 0,
        coinsAwarded: 0,
        level: _level,
      ));
      return;
    }

    final reward = QuestRewardService.calculateMathDash(
      correctAnswers: _score,
      totalQuestions: widget.sessionLength,
      bestStreak: _bestStreak,
    );
    if (reward.stars > 0) {
      await _progressRepository.addStars(reward.stars);
      await _miniGameRepository.markStarEarned(MiniGameIds.mathDash);
    }
    if (reward.coins > 0) await _coinRepository.addCoins(reward.coins);
    if (!mounted) return;
    _feedbackService
        .play(reward.stars > 0 ? SoundEvent.reward : SoundEvent.correct);
    setState(() {
      _reward = reward;
      _phase = _DashPhase.results;
    });
  }

  Future<void> _submit(int optionIndex) async {
    final correct = _question.isCorrect(optionIndex);

    if (_firstAttempt) {
      await _tracker.recordResult(ChallengeCategory.math, correct: correct);
      if (correct) {
        _score++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
      } else {
        // A miss simply resets the streak — nothing earned is removed.
        _streak = 0;
      }
    }
    if (!mounted) return;

    if (!correct) {
      _feedbackService.play(SoundEvent.incorrect);
      setState(() {
        _firstAttempt = false;
        _feedback = QuestEngine
            .encouragements[_questionNumber % QuestEngine.encouragements.length];
        _hint = MathHintService.hintFor(_question);
        _shakeSignal++;
      });
      return;
    }

    if (_questionNumber + 1 >= widget.sessionLength) {
      await _finishSession();
      return;
    }

    _feedbackService.play(SoundEvent.correct);
    setState(() {
      _questionNumber++;
      _feedback = null;
      _hint = null;
      _nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Math Dash')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cream, Color(0xFFDFF3E4)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: switch (_phase) {
              _DashPhase.intro => _IntroView(
                  sessionLength: widget.sessionLength,
                  onStart: _startRound,
                ),
              _DashPhase.playing => _buildPlaying(context),
              _DashPhase.results => _ResultsView(
                  score: _score,
                  total: widget.sessionLength,
                  bestStreak: _bestStreak,
                  reward: _reward!,
                  onPlayAgain: _startRound,
                  onDone: () => Navigator.of(context).pop(),
                ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaying(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DashHud(
          score: _score,
          streak: _streak,
          questionNumber: _questionNumber,
          total: widget.sessionLength,
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            HeroAvatarPreview(profile: _heroProfile, size: 72),
            if (_question.visual != null) ...[
              const SizedBox(width: 12),
              Flexible(
                child: PopIn(
                  key: ValueKey('question_visual_${_question.id}'),
                  child: Text(
                    _question.visual!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 34, height: 1.4),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _question.prompt,
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
                      style: textTheme.bodyLarge
                          ?.copyWith(color: AppColors.gentleWarning),
                    ),
                    if (_hint != null)
                      Text(
                        '💡 ${_hint!.text}',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                  ],
                ),
        ),
        if (_robotActive && !_companionHintUsed) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey('robot_hint_button'),
              onPressed: _useCompanionHint,
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
              for (var i = 0; i < _question.options.length; i++) ...[
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
                    _question.options[i],
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

/// Top status row (brief layout: ⭐ score, 🔥 streak, progress N / M).
class _DashHud extends StatelessWidget {
  const _DashHud({
    required this.score,
    required this.streak,
    required this.questionNumber,
    required this.total,
  });

  final int score;
  final int streak;
  final int questionNumber;
  final int total;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge;

    Widget chip(String text, String semanticLabel) => Semantics(
          label: semanticLabel,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(text, style: style),
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        chip('⭐ $score', '$score correct so far'),
        if (streak >= 2)
          chip('🔥 $streak', '$streak in a row')
        else
          const SizedBox.shrink(),
        chip('${questionNumber + 1} / $total',
            'Question ${questionNumber + 1} of $total'),
      ],
    );
  }
}

class _IntroView extends StatelessWidget {
  const _IntroView({required this.sessionLength, required this.onStart});

  final int sessionLength;
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
          'Solve it. Collect it. Keep moving!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Solve $sessionLength number puzzles! Get '
          '${QuestRewardService.mathDashStarThreshold(sessionLength)} right '
          'on the first try to earn a ⭐',
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
    required this.total,
    required this.bestStreak,
    required this.reward,
    required this.onPlayAgain,
    required this.onDone,
  });

  final int score;
  final int total;
  final int bestStreak;
  final MiniGameReward reward;
  final VoidCallback onPlayAgain;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final starEarned = reward.stars > 0;

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
          'Math Dash complete!',
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'You got $score of $total!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        if (bestStreak >= 2) ...[
          const SizedBox(height: 8),
          Text(
            '🔥 Best streak: $bestStreak in a row',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ],
        const SizedBox(height: 12),
        Text(
          starEarned
              ? 'Super work! +${reward.stars} ⭐  +${reward.coins} 🪙'
              : reward.coins > 0
                  ? 'Great effort! +${reward.coins} 🪙 for your streak!'
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
