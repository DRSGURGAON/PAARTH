import 'dart:math';

import 'chess_game.dart';
import 'chess_models.dart';

/// The lightweight child-level opponent (brief section 7) and the hint
/// provider (section 8). Three levels, all deliberately beatable:
///
/// - **Level 1** — picks a random legal move. A 7-year-old's first
///   opponent should mostly wander.
/// - **Level 2** — takes the biggest free capture if one exists,
///   otherwise wanders.
/// - **Level 3** — one-move lookahead on material: picks the move with
///   the best material outcome after the opponent's best reply. Still
///   only "medium child-level" — no deep search, so the UI never
///   blocks (a few hundred positions at most).
///
/// [suggestMove] reuses the level-3 evaluation to power the child's
/// 💡 hint button.
class ChessAi {
  ChessAi({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const int minLevel = 1;
  static const int maxLevel = 3;

  ChessMove? pickMove(ChessGame game, int level) {
    final moves = game.legalMoves();
    if (moves.isEmpty) return null;
    switch (level.clamp(minLevel, maxLevel)) {
      case 1:
        return moves[_random.nextInt(moves.length)];
      case 2:
        return _greedyCapture(game, moves) ??
            moves[_random.nextInt(moves.length)];
      default:
        return _bestByLookahead(game, moves);
    }
  }

  /// A good move for the side to move — the hint system.
  ChessMove? suggestMove(ChessGame game) {
    final moves = game.legalMoves();
    if (moves.isEmpty) return null;
    return _bestByLookahead(game, moves);
  }

  ChessMove? _greedyCapture(ChessGame game, List<ChessMove> moves) {
    ChessMove? best;
    var bestValue = 0;
    for (final move in moves) {
      final target = game.pieceAt(move.to);
      if (target != null && target.value > bestValue) {
        bestValue = target.value;
        best = move;
      }
    }
    return best;
  }

  ChessMove _bestByLookahead(ChessGame game, List<ChessMove> moves) {
    final mover = game.turn;
    var bestScore = -1000000;
    final bestMoves = <ChessMove>[];

    for (final move in moves) {
      game.play(move);
      int score;
      final replies = game.legalMoves();
      if (replies.isEmpty) {
        // No reply: checkmate is the best outcome, stalemate is flat.
        score = game.isInCheck(game.turn) ? 999999 : 0;
      } else {
        // Opponent replies to minimize our material balance.
        var worst = 1000000;
        for (final reply in replies) {
          game.play(reply);
          final balance = _materialBalance(game, mover);
          game.undo();
          if (balance < worst) worst = balance;
        }
        score = worst;
      }
      game.undo();

      if (score > bestScore) {
        bestScore = score;
        bestMoves
          ..clear()
          ..add(move);
      } else if (score == bestScore) {
        bestMoves.add(move);
      }
    }
    return bestMoves[_random.nextInt(bestMoves.length)];
  }

  int _materialBalance(ChessGame game, PieceColor perspective) {
    var balance = 0;
    for (var s = 0; s < 64; s++) {
      final piece = game.pieceAt(s);
      if (piece == null) continue;
      balance += piece.color == perspective ? piece.value : -piece.value;
    }
    return balance;
  }
}
