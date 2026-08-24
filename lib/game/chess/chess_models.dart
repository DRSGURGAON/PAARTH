/// Core chess data types — pure Dart, no Flutter imports, so the whole
/// engine is unit-testable and UI-independent (brief section 33's
/// isolation requirement, satisfied by our own engine rather than a
/// package — see ChessGame's doc comment for why).
library;

enum PieceColor { white, black }

extension PieceColorX on PieceColor {
  PieceColor get opponent =>
      this == PieceColor.white ? PieceColor.black : PieceColor.white;
}

enum PieceType { pawn, knight, bishop, rook, queen, king }

class ChessPiece {
  const ChessPiece(this.color, this.type);

  final PieceColor color;
  final PieceType type;

  /// Unicode chess glyph — original, universal, no image assets needed.
  String get glyph => switch ((color, type)) {
        (PieceColor.white, PieceType.pawn) => '♙',
        (PieceColor.white, PieceType.knight) => '♘',
        (PieceColor.white, PieceType.bishop) => '♗',
        (PieceColor.white, PieceType.rook) => '♖',
        (PieceColor.white, PieceType.queen) => '♕',
        (PieceColor.white, PieceType.king) => '♔',
        (PieceColor.black, PieceType.pawn) => '♟',
        (PieceColor.black, PieceType.knight) => '♞',
        (PieceColor.black, PieceType.bishop) => '♝',
        (PieceColor.black, PieceType.rook) => '♜',
        (PieceColor.black, PieceType.queen) => '♛',
        (PieceColor.black, PieceType.king) => '♚',
      };

  /// Material value for the lightweight AI (king excluded from trades).
  int get value => switch (type) {
        PieceType.pawn => 1,
        PieceType.knight => 3,
        PieceType.bishop => 3,
        PieceType.rook => 5,
        PieceType.queen => 9,
        PieceType.king => 0,
      };

  String get name => switch (type) {
        PieceType.pawn => 'Pawn',
        PieceType.knight => 'Knight',
        PieceType.bishop => 'Bishop',
        PieceType.rook => 'Rook',
        PieceType.queen => 'Queen',
        PieceType.king => 'King',
      };
}

/// One move from square [from] to square [to] (0–63, row-major from
/// black's back rank at the top; white pawns move toward index 0).
class ChessMove {
  const ChessMove(
    this.from,
    this.to, {
    this.isCastle = false,
    this.isEnPassant = false,
    this.promotesToQueen = false,
  });

  final int from;
  final int to;
  final bool isCastle;
  final bool isEnPassant;
  final bool promotesToQueen;

  @override
  bool operator ==(Object other) =>
      other is ChessMove && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => 'ChessMove($from→$to)';
}

enum ChessStatus { playing, check, checkmate, stalemate, draw }
