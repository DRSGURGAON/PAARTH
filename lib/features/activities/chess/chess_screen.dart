import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../game/chess/chess_ai.dart';
import '../../../game/models/activity_progress.dart';
import '../../../game/repositories/activity_progress_repository.dart';
import '../../../shared/widgets/big_rounded_button.dart';
import 'chess_learn_screen.dart';
import 'chess_play_screen.dart';
import 'chess_puzzle_screen.dart';

/// ♟️ Chess Club — "Think & Play". The activity hub: pick a difficulty
/// and play, learn how each piece moves, or solve starter puzzles.
/// The chosen difficulty persists as the activity's skill level.
class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  late ActivityProgressRepository _activityRepository;
  int _level = 1;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _activityRepository =
        ActivityProgressRepository(AppScope.of(context).storage);
    _level = _activityRepository
        .load(ActivityIds.chess)
        .skillLevel
        .clamp(ChessAi.minLevel, ChessAi.maxLevel);
    _loaded = true;
  }

  Future<void> _setLevel(int level) async {
    await _activityRepository.setSkillLevel(ActivityIds.chess, level);
    if (!mounted) return;
    setState(() => _level = level);
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = _activityRepository.load(ActivityIds.chess);

    return Scaffold(
      appBar: AppBar(title: const Text('Chess Club')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('♟️', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              Text('Think & Play', textAlign: TextAlign.center,
                  style: textTheme.headlineMedium),
              if (progress.sessionsCompleted > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${progress.sessionsCompleted} game'
                  '${progress.sessionsCompleted == 1 ? '' : 's'} played',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 20),
              Text('Pick your opponent:', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var level = 1; level <= 3; level++) ...[
                    Expanded(
                      child: FilledButton(
                        key: ValueKey('chess_level_$level'),
                        onPressed: () => _setLevel(level),
                        style: FilledButton.styleFrom(
                          backgroundColor: _level == level
                              ? AppColors.grapePurple
                              : Colors.white,
                          foregroundColor: _level == level
                              ? Colors.white
                              : AppColors.inkNavy,
                        ),
                        child: Text(switch (level) {
                          1 => 'Easy',
                          2 => 'Medium',
                          _ => 'Clever',
                        }),
                      ),
                    ),
                    if (level < 3) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              BigRoundedButton(
                key: const ValueKey('chess_play_button'),
                label: 'Play Chess!',
                icon: Icons.play_arrow_rounded,
                backgroundColor: AppColors.leafGreen,
                onPressed: () => _open(ChessPlayScreen(level: _level)),
              ),
              const SizedBox(height: 12),
              BigRoundedButton(
                key: const ValueKey('chess_learn_button'),
                label: 'Learn Chess',
                icon: Icons.school_rounded,
                backgroundColor: AppColors.skyBlue,
                onPressed: () => _open(const ChessLearnScreen()),
              ),
              const SizedBox(height: 12),
              BigRoundedButton(
                key: const ValueKey('chess_puzzles_button'),
                label: 'Puzzles',
                icon: Icons.extension_rounded,
                backgroundColor: AppColors.coral,
                onPressed: () => _open(const ChessPuzzleScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
