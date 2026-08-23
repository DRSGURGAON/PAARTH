import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/audio/feedback_service.dart';
import '../../core/audio/sound_event.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/companion_catalog.dart';
import '../../game/models/quest.dart';
import '../../game/models/word_puzzle.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/companion_repository.dart';
import '../../game/repositories/mini_game_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/systems/difficulty_tracker.dart';
import '../../game/systems/quest_engine.dart';
import '../../game/systems/word_puzzle_generator.dart';
import '../../shared/widgets/big_rounded_button.dart';
import '../../shared/widgets/pop_in.dart';

/// One scrambled letter tile. Carries a stable [id] (its original
/// scrambled position) rather than relying on the letter value, so
/// words with repeated letters (e.g. "EGG") behave correctly — tapping
/// either "G" tile moves that specific tile, not "a G".
class LetterTile {
  const LetterTile(this.id, this.letter);

  final int id;
  final String letter;
}

/// Word Builder: shows an emoji, the child taps scrambled letter tiles
/// in order to spell the word (tapping a placed letter returns it, so
/// mistakes are always fixable without penalty). 6 rounds; first-try
/// scoring; predictable reward stated up front.
class WordBuilderScreen extends StatefulWidget {
  const WordBuilderScreen({this.random, super.key});

  final Random? random;

  static const int roundLength = 6;
  static const int starThreshold = 4;
  static const int coinReward = 5;

  @override
  State<WordBuilderScreen> createState() => WordBuilderScreenState();
}

enum _RoundPhase { intro, playing, results }

@visibleForTesting
class WordBuilderScreenState extends State<WordBuilderScreen> {
  late WordPuzzleGenerator _generator;
  late DifficultyTracker _tracker;
  late ProgressRepository _progressRepository;
  late CoinRepository _coinRepository;
  late MiniGameRepository _miniGameRepository;
  late FeedbackService _feedbackService;
  late bool _puppyActive;
  bool _loaded = false;

  _RoundPhase _phase = _RoundPhase.intro;
  late WordPuzzle _puzzle;
  late List<LetterTile> _pool;
  late List<LetterTile?> _placed;
  int _roundNumber = 0;
  int _score = 0;
  bool _firstAttempt = true;
  bool _starEarned = false;
  String? _feedback;

  @visibleForTesting
  WordPuzzle get currentPuzzle => _puzzle;

  @visibleForTesting
  List<LetterTile> get pool => _pool;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _generator = WordPuzzleGenerator(random: widget.random);
    _tracker = DifficultyTracker(storage);
    _progressRepository = ProgressRepository(storage);
    _coinRepository = CoinRepository(storage);
    _miniGameRepository = MiniGameRepository(storage);
    _feedbackService = FeedbackService(storage);
    _puppyActive = CompanionRepository(storage).selectedCompanionId ==
        CompanionIds.puppy;
    _loaded = true;
  }

  void _startGame() {
    setState(() {
      _phase = _RoundPhase.playing;
      _roundNumber = 0;
      _score = 0;
      _starEarned = false;
      _feedback = null;
      _startRound();
    });
  }

  void _startRound() {
    _puzzle = _generator.next(_tracker.levelFor(ChallengeCategory.english));
    final letters = _generator.scrambleLetters(_puzzle.word);
    _pool = [for (var i = 0; i < letters.length; i++) LetterTile(i, letters[i])];
    _placed = List<LetterTile?>.filled(_puzzle.word.length, null);
    _firstAttempt = true;

    // Puppy's hint: sniff out and place the word's first letter so the
    // child only has to finish the rest.
    if (_puppyActive) {
      final firstLetter = _puzzle.word[0];
      final tile = _pool.firstWhere((t) => t.letter == firstLetter);
      _placed[0] = tile;
      _pool = _pool.where((t) => t.id != tile.id).toList();
    }
  }

  /// The letter Puppy already placed in the first slot, or null when
  /// Puppy isn't equipped.
  @visibleForTesting
  String? get puppyPlacedLetter => _placed.isNotEmpty ? _placed[0]?.letter : null;

  void _tapPoolTile(LetterTile tile) {
    final emptySlot = _placed.indexOf(null);
    if (emptySlot == -1) return;
    setState(() {
      _placed[emptySlot] = tile;
      _pool = _pool.where((t) => t.id != tile.id).toList();
      _feedback = null;
    });
    if (!_placed.contains(null)) _checkWord();
  }

  void _tapPlacedTile(int slotIndex) {
    final tile = _placed[slotIndex];
    if (tile == null) return;
    setState(() {
      _placed[slotIndex] = null;
      _pool = [..._pool, tile];
    });
  }

  Future<void> _checkWord() async {
    final attempt = _placed.map((t) => t!.letter).join();
    final correct = attempt == _puzzle.word;

    if (_firstAttempt) {
      await _tracker.recordResult(ChallengeCategory.english, correct: correct);
      if (correct) _score++;
    }
    if (!mounted) return;

    if (!correct) {
      _feedbackService.play(SoundEvent.incorrect);
      setState(() {
        _firstAttempt = false;
        _feedback = QuestEngine
            .encouragements[_roundNumber % QuestEngine.encouragements.length];
        // Give the letters back so the child can try again.
        _pool = [..._pool, ..._placed.whereType<LetterTile>()];
        _placed = List<LetterTile?>.filled(_puzzle.word.length, null);
      });
      return;
    }

    if (_roundNumber + 1 >= WordBuilderScreen.roundLength) {
      if (_score >= WordBuilderScreen.starThreshold) {
        await _progressRepository.addStars(1);
        await _coinRepository.addCoins(WordBuilderScreen.coinReward);
        await _miniGameRepository.markStarEarned(MiniGameIds.wordBuilder);
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
      appBar: AppBar(title: const Text('Word Builder')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_phase) {
            _RoundPhase.intro => _IntroView(onStart: _startGame),
            _RoundPhase.playing => _buildPlaying(context),
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

  Widget _buildPlaying(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Word ${_roundNumber + 1} of ${WordBuilderScreen.roundLength}',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge,
        ),
        const Spacer(),
        Text(
          _puzzle.emoji,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 56),
        ),
        if (_puppyActive) ...[
          const SizedBox(height: 4),
          Text(
            'Puppy sniffed out the first letter! 🐶',
            key: const ValueKey('puppy_hint_label'),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.leafGreen),
          ),
        ],
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            for (var i = 0; i < _placed.length; i++)
              GestureDetector(
                key: ValueKey('slot_$i'),
                onTap: () => _tapPlacedTile(i),
                child: Container(
                  width: 44,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _placed[i] == null
                        ? Colors.white
                        : AppColors.leafGreen,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.inkNavy, width: 2),
                  ),
                  child: Text(
                    _placed[i]?.letter ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
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
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final tile in _pool)
              GestureDetector(
                key: ValueKey('pool_${tile.id}'),
                onTap: () => _tapPoolTile(tile),
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.skyBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tile.letter,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
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
            color: AppColors.leafGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.spellcheck_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Build ${WordBuilderScreen.roundLength} words!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Tap the letters in order to spell the picture. '
          'Get ${WordBuilderScreen.starThreshold} right on the first try '
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
          'You got $score of ${WordBuilderScreen.roundLength}!',
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          starEarned
              ? 'Amazing! You earned +1 ⭐  +${WordBuilderScreen.coinReward} 🪙'
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
