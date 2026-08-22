import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../game/data/companion_catalog.dart';
import '../../game/models/find_scene.dart';
import '../../game/repositories/coin_repository.dart';
import '../../game/repositories/companion_repository.dart';
import '../../game/repositories/mini_game_repository.dart';
import '../../game/repositories/progress_repository.dart';
import '../../game/systems/find_scene_generator.dart';
import '../../shared/widgets/big_rounded_button.dart';

/// Find & Discover: tap every copy of the target object hiding among
/// decoys. No penalty for a wrong tap — it just doesn't count toward a
/// "clean" round. 4 scenes, harder (more items) each round; a scene
/// counts if found with zero wrong taps; 3+ clean scenes earns a ⭐.
class FindDiscoverScreen extends StatefulWidget {
  const FindDiscoverScreen({this.random, super.key});

  final Random? random;

  static const int roundLength = 4;
  static const int starThreshold = 3;
  static const int coinReward = 5;

  /// (targetCount, decoyCount) per round — gets busier as rounds go on.
  static const List<(int, int)> roundConfig = [
    (2, 4),
    (2, 6),
    (3, 6),
    (3, 8),
  ];

  @override
  State<FindDiscoverScreen> createState() => FindDiscoverScreenState();
}

enum _RoundPhase { intro, playing, results }

@visibleForTesting
class FindDiscoverScreenState extends State<FindDiscoverScreen> {
  late FindSceneGenerator _generator;
  late ProgressRepository _progressRepository;
  late CoinRepository _coinRepository;
  late MiniGameRepository _miniGameRepository;
  late bool _monkeyActive;
  bool _loaded = false;

  _RoundPhase _phase = _RoundPhase.intro;
  late FindScene _scene;
  late List<bool> _found;
  final Set<int> _shaking = {};
  int _foundCount = 0;
  bool _mistakeMade = false;
  int _roundNumber = 0;
  int _cleanRounds = 0;
  bool _starEarned = false;
  int _hintedIndex = -1;

  @visibleForTesting
  FindScene get currentScene => _scene;

  /// The index Monkey (the Find & Discover companion) is pointing at
  /// this scene, or -1 when Monkey isn't equipped.
  @visibleForTesting
  int get hintedIndex => _hintedIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _generator = FindSceneGenerator(random: widget.random);
    _progressRepository = ProgressRepository(storage);
    _coinRepository = CoinRepository(storage);
    _miniGameRepository = MiniGameRepository(storage);
    _monkeyActive = CompanionRepository(storage).selectedCompanionId ==
        CompanionIds.monkey;
    _loaded = true;
  }

  void _startGame() {
    setState(() {
      _phase = _RoundPhase.playing;
      _roundNumber = 0;
      _cleanRounds = 0;
      _starEarned = false;
      _startRound();
    });
  }

  void _startRound() {
    final config = FindDiscoverScreen.roundConfig[_roundNumber];
    _scene = _generator.next(targetCount: config.$1, decoyCount: config.$2);
    _found = List<bool>.filled(_scene.items.length, false);
    _foundCount = 0;
    _mistakeMade = false;
    _shaking.clear();
    _hintedIndex = _monkeyActive
        ? _scene.items.indexWhere((item) => item.isTarget)
        : -1;
  }

  Future<void> _tapItem(int index) async {
    if (_found[index]) return;
    final item = _scene.items[index];

    if (item.isTarget) {
      setState(() {
        _found[index] = true;
        _foundCount++;
      });
      if (_foundCount >= _scene.targetCount) await _completeRound();
      return;
    }

    setState(() {
      _mistakeMade = true;
      _shaking.add(index);
    });
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _shaking.remove(index));
  }

  Future<void> _completeRound() async {
    if (!_mistakeMade) _cleanRounds++;

    if (_roundNumber + 1 >= FindDiscoverScreen.roundLength) {
      if (_cleanRounds >= FindDiscoverScreen.starThreshold) {
        await _progressRepository.addStars(1);
        await _coinRepository.addCoins(FindDiscoverScreen.coinReward);
        await _miniGameRepository.markStarEarned(MiniGameIds.findDiscover);
        _starEarned = true;
      }
      if (!mounted) return;
      setState(() => _phase = _RoundPhase.results);
      return;
    }

    setState(() {
      _roundNumber++;
      _startRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find & Discover')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: switch (_phase) {
            _RoundPhase.intro => _IntroView(onStart: _startGame),
            _RoundPhase.playing => _buildPlaying(context),
            _RoundPhase.results => _ResultsView(
                cleanRounds: _cleanRounds,
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
      children: [
        Text(
          'Scene ${_roundNumber + 1} of ${FindDiscoverScreen.roundLength}',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Find ${_scene.targetCount} ${_scene.targetName}! '
          '($_foundCount/${_scene.targetCount})',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: _scene.items.length,
            itemBuilder: (context, index) {
              final item = _scene.items[index];
              final isFound = _found[index];
              final isShaking = _shaking.contains(index);
              final isHinted = !isFound && index == _hintedIndex;

              return GestureDetector(
                key: ValueKey('find_item_$index'),
                onTap: () => _tapItem(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isShaking
                        ? const Color(0xFFFFD3CE)
                        : isFound
                            ? AppColors.leafGreen.withOpacity(0.25)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isHinted
                        ? Border.all(color: AppColors.leafGreen, width: 3)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      isFound && item.isTarget
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.leafGreen, size: 28)
                          : Text(item.emoji,
                              style: const TextStyle(fontSize: 28)),
                      if (isHinted)
                        const Positioned(
                          top: -6,
                          right: -6,
                          child: Icon(
                            Icons.emoji_nature_rounded,
                            color: AppColors.leafGreen,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
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
            color: AppColors.sunshineYellow,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.search_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Explore ${FindDiscoverScreen.roundLength} scenes!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to find everything hiding! Find them all with no '
          'wrong taps in ${FindDiscoverScreen.starThreshold} scenes '
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
    required this.cleanRounds,
    required this.starEarned,
    required this.onPlayAgain,
    required this.onDone,
  });

  final int cleanRounds;
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
          '$cleanRounds of ${FindDiscoverScreen.roundLength} '
          'scenes clean!',
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          starEarned
              ? 'Amazing! You earned +1 ⭐  +${FindDiscoverScreen.coinReward} 🪙'
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
