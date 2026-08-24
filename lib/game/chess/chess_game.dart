import 'chess_models.dart';

/// A real, self-contained chess engine: legal move generation for every
/// piece (castling, en passant, and auto-queen promotion included),
/// check/checkmate/stalemate detection, insufficient-material draws,
/// full undo, and turn handling. Pure Dart, no Flutter imports.
///
/// Why not a package (brief section 33 allows one): this sandbox can't
/// verify a third-party engine compiles against the project's Flutter
/// version, and the rules of chess are small enough to implement and
/// *test exhaustively* here — `chess_game_test.dart` pins every rule.
/// The UI depends only on this class, so swapping in a stronger engine
/// later would touch one file.
class ChessGame {
  ChessGame() {
    _setupInitialPosition();
  }

  /// A custom position — used by Learn mode, puzzles, and tests.
  /// [pieces] maps square index (0–63) to a piece.
  ChessGame.custom(Map<int, ChessPiece> pieces,
      {PieceColor turn = PieceColor.white}) {
    for (final entry in pieces.entries) {
      _board[entry.key] = entry.value;
    }
    _turn = turn;
    // Castling requires untouched kings/rooks on their home squares;
    // custom positions rarely qualify, so rights derive from placement.
    _whiteKingsideRight = _board[60]?.type == PieceType.king &&
        _board[60]?.color == PieceColor.white &&
        _board[63]?.type == PieceType.rook;
    _whiteQueensideRight = _board[60]?.type == PieceType.king &&
        _board[60]?.color == PieceColor.white &&
        _board[56]?.type == PieceType.rook;
    _blackKingsideRight = _board[4]?.type == PieceType.king &&
        _board[4]?.color == PieceColor.black &&
        _board[7]?.type == PieceType.rook;
    _blackQueensideRight = _board[4]?.type == PieceType.king &&
        _board[4]?.color == PieceColor.black &&
        _board[0]?.type == PieceType.rook;
  }

  final List<ChessPiece?> _board = List<ChessPiece?>.filled(64, null);
  PieceColor _turn = PieceColor.white;
  int? _enPassantTarget;
  bool _whiteKingsideRight = true;
  bool _whiteQueensideRight = true;
  bool _blackKingsideRight = true;
  bool _blackQueensideRight = true;

  final List<_Snapshot> _history = [];

  PieceColor get turn => _turn;
  ChessPiece? pieceAt(int square) => _board[square];
  int get movesPlayed => _history.length;
  bool get canUndo => _history.isNotEmpty;

  static int row(int square) => square ~/ 8;
  static int col(int square) => square % 8;
  static int square(int r, int c) => r * 8 + c;
  static bool _onBoard(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;

  void _setupInitialPosition() {
    const backRank = [
      PieceType.rook,
      PieceType.knight,
      PieceType.bishop,
      PieceType.queen,
      PieceType.king,
      PieceType.bishop,
      PieceType.knight,
      PieceType.rook,
    ];
    for (var c = 0; c < 8; c++) {
      _board[square(0, c)] = ChessPiece(PieceColor.black, backRank[c]);
      _board[square(1, c)] = const ChessPiece(PieceColor.black, PieceType.pawn);
      _board[square(6, c)] = const ChessPiece(PieceColor.white, PieceType.pawn);
      _board[square(7, c)] = ChessPiece(PieceColor.white, backRank[c]);
    }
  }

  // ── Move generation ────────────────────────────────────

  /// All fully-legal moves for the side to move.
  List<ChessMove> legalMoves() {
    final moves = <ChessMove>[];
    for (var s = 0; s < 64; s++) {
      if (_board[s]?.color == _turn) moves.addAll(legalMovesFrom(s));
    }
    return moves;
  }

  /// Fully-legal moves for the piece on [from] (empty if none/not its
  /// turn) — what the UI highlights when the child taps a piece.
  List<ChessMove> legalMovesFrom(int from) {
    final piece = _board[from];
    if (piece == null || piece.color != _turn) return const [];
    final moves = <ChessMove>[];
    for (final move in _pseudoMovesFrom(from, piece)) {
      _apply(move);
      final safe = !_isAttacked(_kingSquare(piece.color), piece.color.opponent);
      _undoInternal();
      if (safe) moves.add(move);
    }
    return moves;
  }

  List<ChessMove> _pseudoMovesFrom(int from, ChessPiece piece) {
    final r = row(from);
    final c = col(from);
    final moves = <ChessMove>[];

    void slide(List<List<int>> directions) {
      for (final d in directions) {
        var nr = r + d[0];
        var nc = c + d[1];
        while (_onBoard(nr, nc)) {
          final target = _board[square(nr, nc)];
          if (target == null) {
            moves.add(ChessMove(from, square(nr, nc)));
          } else {
            if (target.color != piece.color) {
              moves.add(ChessMove(from, square(nr, nc)));
            }
            break;
          }
          nr += d[0];
          nc += d[1];
        }
      }
    }

    void step(List<List<int>> offsets) {
      for (final d in offsets) {
        final nr = r + d[0];
        final nc = c + d[1];
        if (!_onBoard(nr, nc)) continue;
        final target = _board[square(nr, nc)];
        if (target == null || target.color != piece.color) {
          moves.add(ChessMove(from, square(nr, nc)));
        }
      }
    }

    switch (piece.type) {
      case PieceType.pawn:
        final dir = piece.color == PieceColor.white ? -1 : 1;
        final startRow = piece.color == PieceColor.white ? 6 : 1;
        final promoRow = piece.color == PieceColor.white ? 0 : 7;
        // Forward one (and two from the start row).
        if (_onBoard(r + dir, c) && _board[square(r + dir, c)] == null) {
          moves.add(ChessMove(from, square(r + dir, c),
              promotesToQueen: r + dir == promoRow));
          if (r == startRow && _board[square(r + 2 * dir, c)] == null) {
            moves.add(ChessMove(from, square(r + 2 * dir, c)));
          }
        }
        // Diagonal captures + en passant.
        for (final dc in [-1, 1]) {
          final nr = r + dir;
          final nc = c + dc;
          if (!_onBoard(nr, nc)) continue;
          final targetSquare = square(nr, nc);
          final target = _board[targetSquare];
          if (target != null && target.color != piece.color) {
            moves.add(ChessMove(from, targetSquare,
                promotesToQueen: nr == promoRow));
          } else if (target == null && targetSquare == _enPassantTarget) {
            moves.add(ChessMove(from, targetSquare, isEnPassant: true));
          }
        }
      case PieceType.knight:
        step(const [
          [-2, -1], [-2, 1], [-1, -2], [-1, 2],
          [1, -2], [1, 2], [2, -1], [2, 1],
        ]);
      case PieceType.bishop:
        slide(const [
          [-1, -1], [-1, 1], [1, -1], [1, 1],
        ]);
      case PieceType.rook:
        slide(const [
          [-1, 0], [1, 0], [0, -1], [0, 1],
        ]);
      case PieceType.queen:
        slide(const [
          [-1, -1], [-1, 1], [1, -1], [1, 1],
          [-1, 0], [1, 0], [0, -1], [0, 1],
        ]);
      case PieceType.king:
        step(const [
          [-1, -1], [-1, 0], [-1, 1], [0, -1],
          [0, 1], [1, -1], [1, 0], [1, 1],
        ]);
        moves.addAll(_castleMoves(from, piece));
    }
    return moves;
  }

  List<ChessMove> _castleMoves(int from, ChessPiece king) {
    final moves = <ChessMove>[];
    final isWhite = king.color == PieceColor.white;
    final home = isWhite ? 60 : 4;
    if (from != home) return moves;
    if (_isAttacked(home, king.color.opponent)) return moves;

    final kingside = isWhite ? _whiteKingsideRight : _blackKingsideRight;
    if (kingside &&
        _board[home + 1] == null &&
        _board[home + 2] == null &&
        _board[home + 3]?.type == PieceType.rook &&
        _board[home + 3]?.color == king.color &&
        !_isAttacked(home + 1, king.color.opponent) &&
        !_isAttacked(home + 2, king.color.opponent)) {
      moves.add(ChessMove(from, home + 2, isCastle: true));
    }

    final queenside = isWhite ? _whiteQueensideRight : _blackQueensideRight;
    if (queenside &&
        _board[home - 1] == null &&
        _board[home - 2] == null &&
        _board[home - 3] == null &&
        _board[home - 4]?.type == PieceType.rook &&
        _board[home - 4]?.color == king.color &&
        !_isAttacked(home - 1, king.color.opponent) &&
        !_isAttacked(home - 2, king.color.opponent)) {
      moves.add(ChessMove(from, home - 2, isCastle: true));
    }
    return moves;
  }

  // ── Attack / status queries ────────────────────────────

  int _kingSquare(PieceColor color) {
    for (var s = 0; s < 64; s++) {
      final piece = _board[s];
      if (piece != null && piece.type == PieceType.king && piece.color == color) {
        return s;
      }
    }
    return -1; // Custom positions in Learn mode may omit a king.
  }

  /// Whether [target] is attacked by any piece of [by]. A missing
  /// target (Learn-mode boards without kings) is never "attacked".
  bool _isAttacked(int target, PieceColor by) {
    if (target < 0) return false;
    final tr = row(target);
    final tc = col(target);

    bool hits(List<List<int>> directions, Set<PieceType> types) {
      for (final d in directions) {
        var nr = tr + d[0];
        var nc = tc + d[1];
        while (_onBoard(nr, nc)) {
          final piece = _board[square(nr, nc)];
          if (piece != null) {
            if (piece.color == by && types.contains(piece.type)) return true;
            break;
          }
          nr += d[0];
          nc += d[1];
        }
      }
      return false;
    }

    if (hits(const [
      [-1, 0], [1, 0], [0, -1], [0, 1],
    ], {PieceType.rook, PieceType.queen})) return true;
    if (hits(const [
      [-1, -1], [-1, 1], [1, -1], [1, 1],
    ], {PieceType.bishop, PieceType.queen})) return true;

    for (final d in const [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1],
    ]) {
      final nr = tr + d[0];
      final nc = tc + d[1];
      if (_onBoard(nr, nc)) {
        final piece = _board[square(nr, nc)];
        if (piece?.color == by && piece?.type == PieceType.knight) return true;
      }
    }

    // Pawns attack toward the target from behind it (relative to their
    // own direction of travel).
    final pawnRow = by == PieceColor.white ? tr + 1 : tr - 1;
    for (final dc in const [-1, 1]) {
      if (_onBoard(pawnRow, tc + dc)) {
        final piece = _board[square(pawnRow, tc + dc)];
        if (piece?.color == by && piece?.type == PieceType.pawn) return true;
      }
    }

    for (final d in const [
      [-1, -1], [-1, 0], [-1, 1], [0, -1],
      [0, 1], [1, -1], [1, 0], [1, 1],
    ]) {
      final nr = tr + d[0];
      final nc = tc + d[1];
      if (_onBoard(nr, nc)) {
        final piece = _board[square(nr, nc)];
        if (piece?.color == by && piece?.type == PieceType.king) return true;
      }
    }
    return false;
  }

  bool isInCheck(PieceColor color) =>
      _isAttacked(_kingSquare(color), color.opponent);

  ChessStatus get status {
    final hasMoves = legalMoves().isNotEmpty;
    final inCheck = isInCheck(_turn);
    if (!hasMoves) return inCheck ? ChessStatus.checkmate : ChessStatus.stalemate;
    if (_insufficientMaterial()) return ChessStatus.draw;
    return inCheck ? ChessStatus.check : ChessStatus.playing;
  }

  bool _insufficientMaterial() {
    final minors = <ChessPiece>[];
    for (final piece in _board) {
      if (piece == null || piece.type == PieceType.king) continue;
      if (piece.type == PieceType.bishop || piece.type == PieceType.knight) {
        minors.add(piece);
        continue;
      }
      return false; // Any pawn/rook/queen means mate is still possible.
    }
    return minors.length <= 1;
  }

  // ── Applying and undoing moves ─────────────────────────

  /// Plays [move] for the side to move. Returns the captured piece, if
  /// any. Callers should only pass moves from [legalMoves]/
  /// [legalMovesFrom].
  ChessPiece? play(ChessMove move) {
    final captured = _apply(move);
    return captured;
  }

  /// Undoes the most recent move (one ply).
  void undo() {
    if (_history.isNotEmpty) _undoInternal();
  }

  ChessPiece? _apply(ChessMove move) {
    _history.add(_Snapshot(
      board: List<ChessPiece?>.of(_board),
      turn: _turn,
      enPassantTarget: _enPassantTarget,
      whiteKingside: _whiteKingsideRight,
      whiteQueenside: _whiteQueensideRight,
      blackKingside: _blackKingsideRight,
      blackQueenside: _blackQueensideRight,
    ));

    final piece = _board[move.from]!;
    var captured = _board[move.to];

    _board[move.to] = move.promotesToQueen
        ? ChessPiece(piece.color, PieceType.queen)
        : piece;
    _board[move.from] = null;

    if (move.isEnPassant) {
      final capturedSquare = square(row(move.from), col(move.to));
      captured = _board[capturedSquare];
      _board[capturedSquare] = null;
    }

    if (move.isCastle) {
      final kingside = col(move.to) == 6;
      final r = row(move.from);
      final rookFrom = square(r, kingside ? 7 : 0);
      final rookTo = square(r, kingside ? 5 : 3);
      _board[rookTo] = _board[rookFrom];
      _board[rookFrom] = null;
    }

    // En passant window: only immediately after a double pawn step.
    _enPassantTarget = null;
    if (piece.type == PieceType.pawn &&
        (row(move.to) - row(move.from)).abs() == 2) {
      _enPassantTarget = square(
          (row(move.to) + row(move.from)) ~/ 2, col(move.from));
    }

    // Castling rights lapse when kings/rooks move or rooks are taken.
    if (piece.type == PieceType.king) {
      if (piece.color == PieceColor.white) {
        _whiteKingsideRight = false;
        _whiteQueensideRight = false;
      } else {
        _blackKingsideRight = false;
        _blackQueensideRight = false;
      }
    }
    for (final s in [move.from, move.to]) {
      if (s == 63) _whiteKingsideRight = false;
      if (s == 56) _whiteQueensideRight = false;
      if (s == 7) _blackKingsideRight = false;
      if (s == 0) _blackQueensideRight = false;
    }

    _turn = _turn.opponent;
    return captured;
  }

  void _undoInternal() {
    final snapshot = _history.removeLast();
    for (var s = 0; s < 64; s++) {
      _board[s] = snapshot.board[s];
    }
    _turn = snapshot.turn;
    _enPassantTarget = snapshot.enPassantTarget;
    _whiteKingsideRight = snapshot.whiteKingside;
    _whiteQueensideRight = snapshot.whiteQueenside;
    _blackKingsideRight = snapshot.blackKingside;
    _blackQueensideRight = snapshot.blackQueenside;
  }
}

class _Snapshot {
  const _Snapshot({
    required this.board,
    required this.turn,
    required this.enPassantTarget,
    required this.whiteKingside,
    required this.whiteQueenside,
    required this.blackKingside,
    required this.blackQueenside,
  });

  final List<ChessPiece?> board;
  final PieceColor turn;
  final int? enPassantTarget;
  final bool whiteKingside;
  final bool whiteQueenside;
  final bool blackKingside;
  final bool blackQueenside;
}
