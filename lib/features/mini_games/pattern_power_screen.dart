import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/audio/feedback_service.dart';
import '../../core/audio/sound_event.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/companion_catalog.dart';
import '../../game/models/mini_game_result.dart';
import '../../game/models/pattern_question.dart';
import '../../game/models/quest.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/companion_repository.dart';
import '../../game/repositories/mini_game_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/systems/difficulty_tracker.dart';
import '../../game/systems/pattern_hint_service.dart';
import '../../game/systems/pattern_question_generator.dart';
import '../../game/systems/quest_engine.dart';
import '../../game/systems/quest_reward_service.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../../shared/widgets/pop_in.dart';
import '../../shared/widgets/shake_widget.dart';

/// Pattern Power — "Spot the pattern. Unlock the adventure!" The jungle
/// lock shows a themed pattern (colors, shapes, animals, objects, or
/// numbers) with the next item missing; the child taps the answer from
/// three big visual choices. Each solved pattern clicks one lock open
/// (🔓 chip); a miss gets encouragement plus a hint that marks the
/// repeating groups. No timers, no penalties.
///
/// Two ways to play, same contract as Math Dash and Memory Master:
/// - **Standalone**: [sessionLength] patterns, payout via
///   [QuestRewardService.calculateMiniGameSession].
/// - **Embedded in a quest** ([embedded] true, for a
///   [PatternPowerChallenge]): pops a [MiniGameSessionResult] on
///   completion; the quest's own rewards pay, nothing double-pays.
class PatternPowerScreen extends StatefulWidget {
  const PatternPowerScreen({
    this.random,
    this.sessionLength = defaultSessionLength,
    this.embedded = false,
    super.key,
  });

  final Random? random;
  final int sessionLength;
  final bool embedded;

  static const int defaultSessionLength = 5;

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
  late FeedbackService _feedbackService;
  late bool _foxActive;
  bool _loaded = false;

  _RoundPhase _phase = _RoundPhase.intro;
  late PatternQuestion _question;
  int _questionNumber = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _level = 1;
  bool _firstAttempt = true;
  bool _justUnlocked = false;
  MiniGameReward? _reward;
  String? _feedback;
  PatternHint? _hint;
  bool _companionHintUsed = false;
  int _shakeSignal = 0;
  final Set<int> _eliminatedOptions = {};

  @visibleForTesting
  PatternQuestion get currentQuestion => _question;

  @visibleForTesting
  bool get hintAvailable => _foxActive;

  @visibleForTesting
  Set<int> get eliminatedOptions => _eliminatedOptions;

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
    _feedbackService = FeedbackService(storage);
    _foxActive =
        CompanionRepository(storage).selectedCompanionId == CompanionIds.fox;
    _loaded = true;
    if (widget.embedded) {
      _resetSession();
      _phase = _RoundPhase.playing;
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
    _justUnlocked = false;
    _nextQuestion();
  }

  void _startRound() {
    setState(() {
      _resetSession();
      _phase = _RoundPhase.playing;
    });
  }

  void _nextQuestion() {
    _level = _tracker.levelFor(ChallengeCategory.logic);
    _question = _generator.next(_level);
    _firstAttempt = true;
    _companionHintUsed = false;
    _eliminatedOptions.clear();
  }

  /// Fox's help: crosses out the first wrong-and-not-yet-eliminated
  /// option, once per question. Never touches the correct index.
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
      _feedbackService.play(SoundEvent.reward);
      Navigator.of(context).pop(MiniGameSessionResult(
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

    final reward = QuestRewardService.calculateMiniGameSession(
      correctAnswers: _score,
      totalQuestions: widget.sessionLength,
      bestStreak: _bestStreak,
    );
    if (reward.stars > 0) {
      await _progressRepository.addStars(reward.stars);
      await _miniGameRepository.markStarEarned(MiniGameIds.patternPower);
    }
    if (reward.coins > 0) await _coinRepository.addCoins(reward.coins);
    if (!mounted) return;
    _feedbackService
        .play(reward.stars > 0 ? SoundEvent.reward : SoundEvent.correct);
    setState(() {
      _reward = reward;
      _phase = _RoundPhase.results;
    });
  }

  Future<void> _submit(int optionIndex) async {
    final correct = _question.isCorrect(optionIndex);

    if (_firstAttempt) {
      await _tracker.recordResult(ChallengeCategory.logic, correct: correct);
      if (correct) {
        _score++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
      } else {
        _streak = 0;
      }
    }
    if (!mounted) return;

    if (!correct) {
      _feedbackService.play(SoundEvent.incorrect);
      setState(() {
        _firstAttempt = false;
        _feedback = QuestEngine.encouragements[
            _questionNumber % QuestEngine.encouragements.length];
        _hint = PatternHintService.hintFor(_question);
        _shakeSignal++;
        _justUnlocked = false;
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
      // The lock visibly reacts: a 🔓 chip pops in with the next
      // pattern and stays until the child answers again.
      _justUnlocked = true;
      _nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pattern Power')),
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
              _RoundPhase.intro => _IntroView(
                  sessionLength: widget.sessionLength,
                  onStart: _startRound,
                ),
              _RoundPhase.playing => _buildPlaying(context),
              _RoundPhase.results => _ResultsView(
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
        _PatternHud(
          score: _score,
          streak: _streak,
          questionNumber: _questionNumber,
          total: widget.sessionLength,
        ),
        const Spacer(),
        _JungleLock(
          key: ValueKey('pattern_lock_${_question.id}'),
          question: _question,
          justUnlocked: _justUnlocked,
        ),
        const SizedBox(height: 16),
        Text(
          _question.prompt,
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
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
                    if (_hint != null) ...[
                      Text(
                        '💡 ${_hint!.text}',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                      if (_hint!.visual != null)
                        Text(
                          _hint!.visual!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20),
                        ),
                    ],
                  ],
                ),
        ),
        if (_foxActive && !_companionHintUsed) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey('fox_hint_button'),
              onPressed: _useCompanionHint,
              icon: const Icon(Icons.pets_rounded, color: AppColors.grapePurple),
              label: const Text('Fox Hint'),
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
                    textStyle: const TextStyle(fontSize: 28),
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

/// The jungle lock holding the pattern: the pattern row inside a card
/// with a lock badge — 🔒 while unsolved, and a popped-in 🔓 chip after
/// the previous pattern was solved (brief: the lock visibly reacts).
class _JungleLock extends StatelessWidget {
  const _JungleLock({
    required this.question,
    required this.justUnlocked,
    super.key,
  });

  final PatternQuestion question;
  final bool justUnlocked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (justUnlocked)
          PopIn(
            key: const ValueKey('lock_opened_chip'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.leafGreen,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '🔓 Pattern unlocked! Great job!',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ),
        PopIn(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.grapePurple, width: 3),
            ),
            child: Column(
              children: [
                const Text('🔒', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  question.visual,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 34, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Top status row: ⭐ score, 🧩 streak (from 2 solved in a row), N / M.
class _PatternHud extends StatelessWidget {
  const _PatternHud({
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
        chip('⭐ $score', '$score solved so far'),
        if (streak >= 2)
          chip('🧩 $streak', '$streak solved in a row')
        else
          const SizedBox.shrink(),
        chip('${questionNumber + 1} / $total',
            'Pattern ${questionNumber + 1} of $total'),
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
          'Spot the pattern. Unlock the adventure!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'The jungle lock hides $sessionLength patterns! Get '
          '${QuestRewardService.sessionStarThreshold(sessionLength)} right '
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
              starEarned ? Icons.lock_open_rounded : Icons.sentiment_satisfied_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '🔓 Pattern Power complete!',
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
            '🧩 Best streak: $bestStreak solved in a row',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ],
        const SizedBox(height: 12),
        Text(
          starEarned
              ? 'The jungle lock opens! +${reward.stars} ⭐  +${reward.coins} 🪙'
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
