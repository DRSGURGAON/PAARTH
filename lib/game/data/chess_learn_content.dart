import '../chess/chess_models.dart';

/// One Learn Chess lesson: a piece, a one-line child-friendly rule, and
/// a starting square for the try-it board (the child taps highlighted
/// squares to move the piece and feel the rule).
class ChessLesson {
  const ChessLesson({
    required this.type,
    required this.blurb,
    required this.startSquare,
  });

  final PieceType type;
  final String blurb;
  final int startSquare;
}

/// Learn Chess content (brief section 9) — one short lesson per piece,
/// no long explanations. Start squares sit mid-board so every move
/// direction is visible.
class ChessLearnContent {
  ChessLearnContent._();

  static const List<ChessLesson> lessons = [
    ChessLesson(
      type: PieceType.pawn,
      blurb: 'The Pawn walks one step forward — and takes sideways!',
      startSquare: 51,
    ),
    ChessLesson(
      type: PieceType.rook,
      blurb: 'The Rook slides in straight lines!',
      startSquare: 35,
    ),
    ChessLesson(
      type: PieceType.knight,
      blurb: '🐴 The Knight jumps in an L shape!',
      startSquare: 35,
    ),
    ChessLesson(
      type: PieceType.bishop,
      blurb: 'The Bishop slides on the slanted lines!',
      startSquare: 35,
    ),
    ChessLesson(
      type: PieceType.queen,
      blurb: 'The Queen slides any way she likes!',
      startSquare: 35,
    ),
    ChessLesson(
      type: PieceType.king,
      blurb: 'The King steps one square — keep him safe!',
      startSquare: 35,
    ),
  ];
}
