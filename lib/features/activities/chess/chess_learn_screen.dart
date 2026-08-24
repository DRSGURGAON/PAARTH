import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../game/chess/chess_game.dart';
import '../../../game/chess/chess_models.dart';
import '../../../game/data/chess_learn_content.dart';
import '../../../shared/widgets/pop_in.dart';
import 'chess_board_view.dart';

/// 🧠 Learn Chess: one short lesson per piece — a one-line rule, then a
/// try-it board where the child moves the real piece with real rules
/// (highlights show every legal square). No reading beyond one line.
class ChessLearnScreen extends StatefulWidget {
  const ChessLearnScreen({super.key});

  @override
  State<ChessLearnScreen> createState() => _ChessLearnScreenState();
}

class _ChessLearnScreenState extends State<ChessLearnScreen> {
  late ChessLesson _lesson;
  late ChessGame _game;
  late int _pieceSquare;
  int? _selected;
  Set<int> _legalTargets = {};

  @override
  void initState() {
    super.initState();
    _loadLesson(ChessLearnContent.lessons.first);
  }

  void _loadLesson(ChessLesson lesson) {
    _lesson = lesson;
    _pieceSquare = lesson.startSquare;
    _rebuildBoard();
  }

  /// The try-board holds just this one white piece; after each move the
  /// board is rebuilt with the piece at its new home so the child can
  /// keep moving it forever — pure sandbox, no turns.
  void _rebuildBoard() {
    _game = ChessGame.custom(
      {_pieceSquare: ChessPiece(PieceColor.white, _lesson.type)},
    );
    _selected = null;
    _legalTargets = {};
  }

  void _onSquareTap(int square) {
    setState(() {
      if (_legalTargets.contains(square)) {
        _pieceSquare = square;
        _rebuildBoard();
        return;
      }
      if (square == _pieceSquare) {
        _selected = square;
        _legalTargets =
            _game.legalMovesFrom(square).map((m) => m.to).toSet();
      } else {
        _selected = null;
        _legalTargets = {};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final piece = ChessPiece(PieceColor.white, _lesson.type);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn Chess')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ChessLearnContent.lessons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final lesson = ChessLearnContent.lessons[index];
                    final selected = lesson.type == _lesson.type;
                    return FilledButton(
                      key: ValueKey('lesson_${lesson.type.name}'),
                      onPressed: () => setState(() => _loadLesson(lesson)),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            selected ? AppColors.grapePurple : Colors.white,
                        foregroundColor:
                            selected ? Colors.white : AppColors.inkNavy,
                      ),
                      child: Text(
                        '${ChessPiece(PieceColor.white, lesson.type).glyph} '
                        '${ChessPiece(PieceColor.white, lesson.type).name}',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              PopIn(
                key: ValueKey('lesson_blurb_${_lesson.type.name}'),
                child: Text(
                  '${piece.glyph} ${_lesson.blurb}',
                  key: const ValueKey('lesson_blurb'),
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap the piece, then tap a glowing square!',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
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
            ],
          ),
        ),
      ),
    );
  }
}
