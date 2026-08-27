import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/audio/feedback_service.dart';
import '../../core/audio/sound_event.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/companion_catalog.dart';
import '../../game/models/mini_game_result.dart';
import '../../game/models/quick_challenge_round.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/companion_repository.dart';
import '../../game/repositories/mini_game_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/systems/quest_engine.dart';
import '../../game/systems/quest_reward_service.dart';
import '../../game/systems/quick_challenge_generator.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../../shared/widgets/pop_in.dart';
import '../../shared/widgets/shake_widget.dart';

/// Quick Challenge — "Fast fingers, quick eyes!" Short tap / count /
/// match / avoid rounds from the brief's section 21 (ten authored
/// templates, see [QuickChallengeGenerator]). Each round shows a
/// gentle [roundSeconds]-second timer; running out is never a
/// punishment — the round simply resets with encouragement and the
/// child tries again (it only stops counting as a first-try success,
/// the same rule a wrong tap follows). Standalone only — quests embed
/// the deeper mini-games instead — with payout via
/// [QuestRewardService.calculateMiniGameSession].
class QuickChallengeScreen extends StatefulWidget {
  const QuickChallengeScreen({
    this.random,
    this.sessionLength = defaultSessionLength,
    super.key,
  });

  final Random? random;
  final int sessionLength;

  static const int defaultSessionLength = 5;
  static const int roundSeconds = 25;

  /// Cheetah's help: extra breathing room on every round timer.
  static const int cheetahBonusSeconds = 10;

  @override
  State<QuickChallengeScreen> createState() => QuickChallengeScreenState();
}

enum _RoundPhase { intro, playing, results }

@visibleForTesting
class QuickChallengeScreenState extends State<QuickChallengeScreen> {
  late QuickChallengeGenerator _generator;
  late ProgressRepository _progressRepository;
  late CoinRepository _coinRepository;
  late MiniGameRepository _miniGameRepository;
  late FeedbackService _feedbackService;
  late bool _cheetahActive;
  bool _loaded = false;

  _RoundPhase _phase = _RoundPhase.intro;
  late QuickChallengeRound _round;
  final Set<int> _tappedTargets = {};
  int _roundNumber = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _roundClean = true;
  MiniGameReward? _reward;
  String? _feedback;
  int _shakeSignal = 0;
  Timer? _timer;
  int _secondsLeft = QuickChallengeScreen.roundSeconds;

  @visibleForTesting
  QuickChallengeRound get currentRound => _round;

  @visibleForTesting
  int get secondsLeft => _secondsLeft;

  /// The full countdown a round starts from, with Cheetah's bonus.
  int get _roundStartSeconds =>
      QuickChallengeScreen.roundSeconds +
      (_cheetahActive ? QuickChallengeScreen.cheetahBonusSeconds : 0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _generator = QuickChallengeGenerator(random: widget.random);
    _progressRepository = ProgressRepository(storage);
    _coinRepository = CoinRepository(storage);
    _miniGameRepository = MiniGameRepository(storage);
    _feedbackService = FeedbackService(storage);
    _cheetahActive = CompanionRepository(storage).selectedCompanionId ==
        CompanionIds.cheetah;
    _loaded = true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _roundNumber = 0;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _reward = null;
      _nextRound();
      _phase = _RoundPhase.playing;
    });
  }

  void _nextRound() {
    _round = _generator.next();
    _tappedTargets.clear();
    _roundClean = true;
    _feedback = null;
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _secondsLeft = _roundStartSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _onTimeUp();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  /// Gentle timeout: the round resets (taps cleared, fresh timer) with
  /// encouragement. No lives lost, nothing ends — it just no longer
  /// counts as a first-try success.
  void _onTimeUp() {
    _feedbackService.play(SoundEvent.incorrect);
    setState(() {
      _roundClean = false;
      _tappedTargets.clear();
      _feedback = "Time flew by! Let's try this one again — no rush.";
      _shakeSignal++;
    });
    _restartTimer();
  }

  Future<void> _tapTile(int index) async {
    if (_phase != _RoundPhase.playing) return;
    if (_round.isTarget(index)) {
      if (_tappedTargets.contains(index)) return;
      setState(() {
        _tappedTargets.add(index);
        _feedback = null;
      });
      if (_tappedTargets.length >= _round.targetIndices.length) {
        await _finishRound();
      } else {
        _feedbackService.play(SoundEvent.correct);
      }
      return;
    }
    // A decoy tap: encouragement, streak protection lost, keep going.
    _feedbackService.play(SoundEvent.incorrect);
    setState(() {
      _roundClean = false;
      _feedback = QuestEngine
          .encouragements[_roundNumber % QuestEngine.encouragements.length];
      _shakeSignal++;
    });
  }

  Future<void> _finishRound() async {
    _timer?.cancel();
    if (_roundClean) {
      _score++;
      _streak++;
      _bestStreak = max(_bestStreak, _streak);
    } else {
      _streak = 0;
    }

    if (_roundNumber + 1 >= widget.sessionLength) {
      await _finishSession();
      return;
    }
    _feedbackService.play(SoundEvent.correct);
    setState(() {
      _roundNumber++;
      _nextRound();
    });
  }

  Future<void> _finishSession() async {
    final reward = QuestRewardService.calculateMiniGameSession(
      correctAnswers: _score,
      totalQuestions: widget.sessionLength,
      bestStreak: _bestStreak,
    );
    if (reward.stars > 0) {
      await _progressRepository.addStars(reward.stars);
      await _miniGameRepository.markStarEarned(MiniGameIds.quickChallenge);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Challenge')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cream, Color(0xFFFCE8D9)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: switch (_phase) {
              _RoundPhase.intro => _IntroView(
                  sessionLength: widget.sessionLength,
                  onStart: _startSession,
                ),
              _RoundPhase.playing => _buildPlaying(context),
              _RoundPhase.results => _ResultsView(
                  score: _score,
                  total: widget.sessionLength,
                  bestStreak: _bestStreak,
                  reward: _reward!,
                  onPlayAgain: _startSession,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _HudChip(
              text: '⭐ $_score',
              semanticLabel: '$_score rounds aced so far',
            ),
            _HudChip(
              key: const ValueKey('round_timer'),
              text: '⏱️ $_secondsLeft',
              semanticLabel: '$_secondsLeft seconds left, no rush',
            ),
            _HudChip(
              text: '${_roundNumber + 1} / ${widget.sessionLength}',
              semanticLabel:
                  'Round ${_roundNumber + 1} of ${widget.sessionLength}',
            ),
          ],
        ),
        const Spacer(),
        Text(
          _round.instruction,
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        if (_round.visual != null) ...[
          const SizedBox(height: 12),
          PopIn(
            key: ValueKey('round_visual_$_roundNumber'),
            child: Text(
              _round.visual!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36, height: 1.3),
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: _feedback == null
              ? null
              : Text(
                  _feedback!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge
                      ?.copyWith(color: AppColors.gentleWarning),
                ),
        ),
        ShakeWidget(
          shakeSignal: _shakeSignal,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < _round.tiles.length; i++)
                _TileButton(
                  key: ValueKey('tile_$i'),
                  label: _round.tiles[i],
                  done: _tappedTargets.contains(i),
                  onTap: () => _tapTile(i),
                ),
            ],
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _TileButton extends StatelessWidget {
  const _TileButton({
    required this.label,
    required this.done,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: FilledButton(
        onPressed: done ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: done ? AppColors.leafGreen : Colors.white,
          disabledBackgroundColor: AppColors.leafGreen,
          foregroundColor: AppColors.inkNavy,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: done
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 40)
            : Text(label, style: const TextStyle(fontSize: 32)),
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.text,
    required this.semanticLabel,
    super.key,
  });

  final String text;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      ),
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
            Icons.bolt_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Fast fingers, quick eyes!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          '$sessionLength speedy rounds — tap, count, and match before '
          'the friendly timer runs out! Ace '
          '${QuestRewardService.sessionStarThreshold(sessionLength)} rounds '
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
                  ? Icons.bolt_rounded
                  : Icons.sentiment_satisfied_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '⚡ Quick Challenge complete!',
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'You aced $score of $total rounds!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        if (bestStreak >= 2) ...[
          const SizedBox(height: 8),
          Text(
            '⚡ Best streak: $bestStreak aced in a row',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ],
        const SizedBox(height: 12),
        Text(
          starEarned
              ? 'Lightning fast! +${reward.stars} ⭐  +${reward.coins} 🪙'
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
