import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../game/chess/chess_game.dart';
import '../../../game/chess/chess_models.dart';

/// The 8×8 board, shared by Play, Learn, and Puzzle screens. Pure
/// presentation: pieces come from [pieceAt], taps go out via [onTap],
/// and highlights (selected square, legal targets, hint arrowheads)
/// are painted from the caller's state — so the same board serves a
/// full game, a one-piece lesson, and a puzzle without changes.
class ChessBoardView extends StatelessWidget {
  const ChessBoardView({
    required this.pieceAt,
    required this.onTap,
    this.selected,
    this.legalTargets = const {},
    this.hintFrom,
    this.hintTo,
    super.key,
  });

  final ChessPiece? Function(int square) pieceAt;
  final ValueChanged<int> onTap;
  final int? selected;
  final Set<int> legalTargets;
  final int? hintFrom;
  final int? hintTo;

  /// 'a1'-style coordinate for semantics.
  static String coordinate(int square) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + ChessGame.col(square));
    final rank = 8 - ChessGame.row(square);
    return '$file$rank';
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inkNavy, width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var r = 0; r < 8; r++)
              Expanded(
                child: Row(
                  children: [
                    for (var c = 0; c < 8; c++)
                      Expanded(child: _buildSquare(ChessGame.square(r, c))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquare(int square) {
    final piece = pieceAt(square);
    final isLight = (ChessGame.row(square) + ChessGame.col(square)).isEven;
    final isSelected = selected == square;
    final isTarget = legalTargets.contains(square);
    final isHint = hintFrom == square || hintTo == square;

    return Semantics(
      button: true,
      label: piece == null
          ? 'Empty square ${coordinate(square)}'
          : '${piece.color == PieceColor.white ? 'Your' : 'Black'} '
              '${piece.name} on ${coordinate(square)}',
      child: GestureDetector(
        key: ValueKey('square_$square'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(square),
        child: Container(
          color: isSelected
              ? AppColors.sunshineYellow
              : isHint
                  ? AppColors.skyBlue.withValues(alpha: 0.55)
                  : isLight
                      ? const Color(0xFFF6E7C8)
                      : const Color(0xFF9BB56E),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (piece != null)
                FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      piece.glyph,
                      style: const TextStyle(fontSize: 32, height: 1),
                    ),
                  ),
                ),
              if (isTarget)
                Container(
                  width: piece == null ? 14 : 26,
                  height: piece == null ? 14 : 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: piece == null
                        ? AppColors.leafGreen.withValues(alpha: 0.8)
                        : Colors.transparent,
                    border: piece == null
                        ? null
                        : Border.all(color: AppColors.coral, width: 3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
