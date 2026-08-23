import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/audio/feedback_service.dart';
import '../../core/audio/sound_event.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/companion_catalog.dart';
import '../../game/models/memory_round.dart';
import '../../game/models/mini_game_result.dart';
import '../../game/models/quest.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/companion_repository.dart';
import '../../game/repositories/mini_game_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/systems/difficulty_tracker.dart';
import '../../game/systems/memory_round_generator.dart';
import '../../game/systems/quest_engine.dart';
import '../../game/systems/quest_reward_service.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../../shared/widgets/pop_in.dart';
import '../../shared/widgets/shake_widget.dart';

/// Memory Master — "Remember it. Find it. Win it!" Jungle friends
/// appear at named scene spots, hide, then a question asks what was
/// remembered (which one you saw / where the panda was / and friends).
/// Gentle observation phase with a soft progress bar — never a numeric
/// countdown — and a once-per-round "Look again" hint after a miss.
///
/// Two ways to play, same contract as Math Dash:
/// - **Standalone**: [sessionLength] rounds, payout decided by
///   [QuestRewardService.calculateMiniGameSession].
/// - **Embedded in a quest** ([embedded] true, for a
///   [MemoryMasterChallenge]): pops a [MiniGameSessionResult] on
///   completion; the quest's own rewards pay, nothing double-pays.
class MemoryMasterScreen extends StatefulWidget {
  const MemoryMasterScreen({
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

  /// Invalidates any still-pending study timer from an earlier round or
  /// an earlier "Look again" peek — only the newest timer may advance
  /// the phase.
  int _studyToken = 0;

  int _roundNumber = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _level = 1;
  bool _firstAttempt = true;
  bool _lookAgainUsed = false;
  MiniGameReward? _reward;
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
    if (widget.embedded) {
      _resetSession();
      _startRound();
    }
  }

  void _resetSession() {
    _roundNumber = 0;
    _score = 0;
    _streak = 0;
    _bestStreak = 0;
    _reward = null;
    _feedback = null;
  }

  void _startGame() {
    setState(() {
      _resetSession();
      _startRound();
    });
  }

  void _startRound() {
    _level = _tracker.levelFor(ChallengeCategory.memory);
    _round = _generator.next(_level);
    _firstAttempt = true;
    _lookAgainUsed = false;
    _studyDuration = _pandaActive
        ? Duration(
            microseconds: (_round.studyDuration.inMicroseconds * 3) ~/ 2,
          )
        : _round.studyDuration;
    _beginStudy(_studyDuration);
  }

  /// Shows the scene for [duration], then flips to answering — unless a
  /// newer study phase superseded this one or the screen went away.
  void _beginStudy(Duration duration) {
    _phase = _RoundPhase.studying;
    final token = ++_studyToken;
    Future.delayed(duration, () {
      if (!mounted || _studyToken != token || _phase != _RoundPhase.studying) {
        return;
      }
      setState(() => _phase = _RoundPhase.answering);
    });
  }

  /// The once-per-round memory hint: a short second look at the scene,
  /// then back to the question (brief: hints help the child understand
  /// — for memory, that means another careful look, not the answer).
  void _lookAgain() {
    if (_lookAgainUsed) return;
    setState(() {
      _lookAgainUsed = true;
      _feedback = null;
      _beginStudy(_studyDuration ~/ 2);
    });
  }

  Future<void> _finishSession() async {
    if (widget.embedded) {
      _feedbackService.play(SoundEvent.correct);
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
      await _miniGameRepository.markStarEarned(MiniGameIds.memoryMaster);
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
    final correct = _round.question.isCorrect(optionIndex);

    if (_firstAttempt) {
      await _tracker.recordResult(ChallengeCategory.memory, correct: correct);
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
        _feedback = QuestEngine
            .encouragements[_roundNumber % QuestEngine.encouragements.length];
        _shakeSignal++;
      });
      return;
    }

    if (_roundNumber + 1 >= widget.sessionLength) {
      await _finishSession();
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
                  onStart: _startGame,
                ),
              _RoundPhase.studying => _buildStudying(context),
              _RoundPhase.answering => _buildAnswering(context),
              _RoundPhase.results => _ResultsView(
                  score: _score,
                  total: widget.sessionLength,
                  bestStreak: _bestStreak,
                  reward: _reward!,
                  onPlayAgain: _startGame,
                  onDone: () => Navigator.of(context).pop(),
                ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHud() {
    return _MemoryHud(
      score: _score,
      streak: _streak,
      roundNumber: _roundNumber,
      total: widget.sessionLength,
    );
  }

  Widget _buildStudying(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _buildHud(),
        const Spacer(),
        Text(
          '👀 Watch carefully!',
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
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final placement in _round.placements)
              _SceneCard(
                key: ValueKey('scene_${placement.object.id}'),
                placement: placement,
              ),
          ],
        ),
        const SizedBox(height: 24),
        // A soft fill bar, not a numeric countdown (brief section 7).
        // Keyed by token so a "Look again" peek restarts the sweep.
        TweenAnimationBuilder<double>(
          key: ValueKey('study_progress_$_studyToken'),
          tween: Tween(begin: 0, end: 1),
          duration: _studyDuration,
          builder: (context, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: Colors.white,
              color: AppColors.leafGreen,
            ),
          ),
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
        _buildHud(),
        const Spacer(),
        Text(
          question.prompt,
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
                    if (!_lookAgainUsed)
                      TextButton.icon(
                        key: const ValueKey('look_again_button'),
                        onPressed: _lookAgain,
                        icon: const Icon(Icons.visibility_rounded,
                            color: AppColors.skyBlue),
                        label: const Text('Look again'),
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

/// One jungle friend at their scene spot — a little diorama card rather
/// than a bare emoji, so the scene reads as "discovering things in the
/// jungle" (brief section 5).
class _SceneCard extends StatelessWidget {
  const _SceneCard({required this.placement, super.key});

  final MemoryPlacement placement;

  @override
  Widget build(BuildContext context) {
    return PopIn(
      child: Semantics(
        label: '${placement.object.label} ${placement.spot.label}',
        child: Container(
          width: 88,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(placement.object.emoji,
                  style: const TextStyle(fontSize: 40)),
              Text(placement.spot.emoji, style: const TextStyle(fontSize: 22)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Top status row: ⭐ score, 🧠 streak (from 2 remembered in a row),
/// round progress.
class _MemoryHud extends StatelessWidget {
  const _MemoryHud({
    required this.score,
    required this.streak,
    required this.roundNumber,
    required this.total,
  });

  final int score;
  final int streak;
  final int roundNumber;
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
        chip('⭐ $score', '$score remembered so far'),
        if (streak >= 2)
          chip('🧠 $streak', '$streak remembered in a row')
        else
          const SizedBox.shrink(),
        chip('${roundNumber + 1} / $total',
            'Round ${roundNumber + 1} of $total'),
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
          'Remember it. Find it. Win it!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'The jungle friends are hiding! Watch closely, then answer '
          'from memory. Get '
          '${QuestRewardService.sessionStarThreshold(sessionLength)} right '
          'on the first try to earn a ⭐',
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
          'Memory Master complete!',
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
            '🧠 Best streak: $bestStreak remembered in a row',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ],
        const SizedBox(height: 12),
        Text(
          starEarned
              ? 'Super memory! +${reward.stars} ⭐  +${reward.coins} 🪙'
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
