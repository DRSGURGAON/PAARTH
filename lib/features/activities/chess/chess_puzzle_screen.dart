import 'package:flutter/material.dart';

import '../../../core/audio/feedback_service.dart';
import '../../../core/audio/sound_event.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../game/chess/chess_game.dart';
import '../../../game/chess/chess_models.dart';
import '../../../game/data/chess_puzzles.dart';
import '../../../game/models/activity_progress.dart';
import '../../../game/repositories/activity_progress_repository.dart';
import '../../../shared/widgets/big_rounded_button.dart';
import 'chess_board_view.dart';

/// 🧩 Chess puzzles: tiny one-move positions ("Can you capture the
/// piece?"). The engine itself judges success, a miss just resets the
/// position with gentle encouragement, and solved puzzles are ticked
/// off in the activity's achievements.
class ChessPuzzleScreen extends StatefulWidget {
  const ChessPuzzleScreen({super.key});

  @override
  State<ChessPuzzleScreen> createState() => _ChessPuzzleScreenState();
}

class _ChessPuzzleScreenState extends State<ChessPuzzleScreen> {
  late ActivityProgressRepository _activityRepository;
  late FeedbackService _feedbackService;
  bool _loaded = false;

  late ChessPuzzle _puzzle;
  late ChessGame _game;
  int? _selected;
  Set<int> _legalTargets = {};
  String? _feedback;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _loadPuzzle(ChessPuzzles.all.first);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final storage = AppScope.of(context).storage;
    _activityRepository = ActivityProgressRepository(storage);
    _feedbackService = FeedbackService(storage);
    _loaded = true;
  }

  void _loadPuzzle(ChessPuzzle puzzle) {
    _puzzle = puzzle;
    _game = ChessGame.custom(Map.of(puzzle.pieces));
    _selected = null;
    _legalTargets = {};
    _feedback = null;
    _solved = false;
  }

  Future<void> _onSquareTap(int square) async {
    if (_solved) return;

    if (_legalTargets.contains(square) && _selected != null) {
      final move =
          _game.legalMovesFrom(_selected!).firstWhere((m) => m.to == square);
      await _tryMove(move);
      return;
    }

    final piece = _game.pieceAt(square);
    setState(() {
      if (piece != null && piece.color == PieceColor.white) {
        _selected = square;
        _legalTargets = _game.legalMovesFrom(square).map((m) => m.to).toSet();
      } else {
        _selected = null;
        _legalTargets = {};
      }
    });
  }

  Future<void> _tryMove(ChessMove move) async {
    final captured = _game.play(move);
    final achieved = switch (_puzzle.goal) {
      ChessPuzzleGoal.capture => captured != null,
      ChessPuzzleGoal.check => _game.isInCheck(PieceColor.black),
      ChessPuzzleGoal.checkmate => _game.status == ChessStatus.checkmate,
    };

    if (achieved) {
      _feedbackService.play(SoundEvent.reward);
      await _activityRepository.addAchievement(
          ActivityIds.chess, 'puzzle_${_puzzle.id}');
      if (!mounted) return;
      setState(() {
        _solved = true;
        _selected = null;
        _legalTargets = {};
        _feedback = '🎉 You did it!';
      });
    } else {
      _feedbackService.play(SoundEvent.incorrect);
      setState(() {
        // Gentle reset — the position comes back, nothing is lost.
        _game.undo();
        _selected = null;
        _legalTargets = {};
        _feedback = "Almost! Let's try again!";
      });
    }
  }

  void _nextPuzzle() {
    final index = ChessPuzzles.all.indexOf(_puzzle);
    setState(() {
      _loadPuzzle(ChessPuzzles.all[(index + 1) % ChessPuzzles.all.length]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final solvedIds =
        _activityRepository.load(ActivityIds.chess).achievements;

    return Scaffold(
      appBar: AppBar(title: const Text('Chess Puzzles')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ChessPuzzles.all.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final puzzle = ChessPuzzles.all[index];
                    final isCurrent = puzzle.id == _puzzle.id;
                    final isSolved =
                        solvedIds.contains('puzzle_${puzzle.id}');
                    return FilledButton(
                      key: ValueKey('puzzle_${puzzle.id}'),
                      onPressed: () => setState(() => _loadPuzzle(puzzle)),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            isCurrent ? AppColors.coral : Colors.white,
                        foregroundColor:
                            isCurrent ? Colors.white : AppColors.inkNavy,
                      ),
                      child: Text('${isSolved ? '✓ ' : ''}${index + 1}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(_puzzle.title, style: textTheme.headlineMedium),
              Text(
                _puzzle.instruction,
                key: const ValueKey('puzzle_instruction'),
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 28,
                child: _feedback == null
                    ? null
                    : Text(
                        _feedback!,
                        key: const ValueKey('puzzle_feedback'),
                        style: textTheme.titleMedium?.copyWith(
                          color: _solved
                              ? AppColors.leafGreen
                              : AppColors.gentleWarning,
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: ChessBoardView(
                    pieceAt: _game.pieceAt,
                    onTap: _onSquareTap,
                    selected: _selected,
                    legalTargets: _legalTargets,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_solved)
                BigRoundedButton(
                  key: const ValueKey('next_puzzle_button'),
                  label: 'Next Puzzle!',
                  icon: Icons.arrow_forward_rounded,
                  backgroundColor: AppColors.leafGreen,
                  onPressed: _nextPuzzle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
