import '../chess/chess_models.dart';

/// What a puzzle asks the child to do in one move.
enum ChessPuzzleGoal { capture, check, checkmate }

/// One single-move chess puzzle: a small authored position, a goal, and
/// a short instruction. The engine itself judges success (a capture
/// happened / the enemy king is in check / checkmate), so puzzles can
/// never claim a result the rules don't back up.
class ChessPuzzle {
  const ChessPuzzle({
    required this.id,
    required this.title,
    required this.instruction,
    required this.goal,
    required this.pieces,
  });

  final String id;
  final String title;
  final String instruction;
  final ChessPuzzleGoal goal;

  /// Square index (0–63) → piece. White to move in every puzzle.
  final Map<int, ChessPiece> pieces;
}

/// Age-appropriate starter puzzles (brief section 10) — capture, check,
/// and mate-in-one, all tiny positions. Square indices are row*8+col
/// with black's side at the top; white moves toward row 0.
class ChessPuzzles {
  ChessPuzzles._();

  static const List<ChessPuzzle> all = [
    ChessPuzzle(
      id: 'capture_pawn',
      title: 'Snack Time!',
      instruction: 'Can you capture the black pawn?',
      goal: ChessPuzzleGoal.capture,
      pieces: {
        27: ChessPiece(PieceColor.black, PieceType.pawn), // d5
        36: ChessPiece(PieceColor.white, PieceType.pawn), // e4
        60: ChessPiece(PieceColor.white, PieceType.king),
        4: ChessPiece(PieceColor.black, PieceType.king),
      },
    ),
    ChessPuzzle(
      id: 'capture_knight',
      title: 'Rook to the Rescue!',
      instruction: 'Can you capture the black knight?',
      goal: ChessPuzzleGoal.capture,
      pieces: {
        28: ChessPiece(PieceColor.black, PieceType.knight), // e5
        60: ChessPiece(PieceColor.white, PieceType.king),
        36: ChessPiece(PieceColor.white, PieceType.rook), // e4
        0: ChessPiece(PieceColor.black, PieceType.king),
      },
    ),
    ChessPuzzle(
      id: 'check_rook',
      title: 'Say Check!',
      instruction: 'Can you check the black king?',
      goal: ChessPuzzleGoal.check,
      pieces: {
        4: ChessPiece(PieceColor.black, PieceType.king), // e8
        35: ChessPiece(PieceColor.white, PieceType.rook), // d5
        60: ChessPiece(PieceColor.white, PieceType.king),
      },
    ),
    ChessPuzzle(
      id: 'check_queen',
      title: 'Queen Says Hello!',
      instruction: 'Can you check the black king?',
      goal: ChessPuzzleGoal.check,
      pieces: {
        2: ChessPiece(PieceColor.black, PieceType.king), // c8
        45: ChessPiece(PieceColor.white, PieceType.queen), // f3
        62: ChessPiece(PieceColor.white, PieceType.king),
      },
    ),
    ChessPuzzle(
      id: 'mate_back_rank',
      title: 'The Big Finish!',
      instruction: 'Can you checkmate the black king?',
      goal: ChessPuzzleGoal.checkmate,
      pieces: {
        6: ChessPiece(PieceColor.black, PieceType.king), // g8
        13: ChessPiece(PieceColor.black, PieceType.pawn), // f7
        14: ChessPiece(PieceColor.black, PieceType.pawn), // g7
        15: ChessPiece(PieceColor.black, PieceType.pawn), // h7
        32: ChessPiece(PieceColor.white, PieceType.rook), // a4
        62: ChessPiece(PieceColor.white, PieceType.king),
      },
    ),
    ChessPuzzle(
      id: 'mate_queen_support',
      title: 'Team Up!',
      instruction: 'Can you checkmate the black king?',
      goal: ChessPuzzleGoal.checkmate,
      pieces: {
        4: ChessPiece(PieceColor.black, PieceType.king), // e8
        19: ChessPiece(PieceColor.white, PieceType.queen), // d6
        20: ChessPiece(PieceColor.white, PieceType.king), // e6
      },
    ),
  ];
}
