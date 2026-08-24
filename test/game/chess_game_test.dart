import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/chess/chess_game.dart';
import 'package:super_kid_adventure/game/chess/chess_models.dart';

/// Engine rule coverage. Squares are row*8+col with black's back rank
/// at row 0 — so e2 = 52, e4 = 36, e8 = 4, a1-style coordinates map as
/// sq(8-rank, file).
void main() {
  int sq(int r, int c) => r * 8 + c;

  ChessMove moveTo(ChessGame game, int from, int to) =>
      game.legalMovesFrom(from).firstWhere((m) => m.to == to);

  group('ChessGame — setup and basic movement', () {
    test('the initial position has 32 pieces and 20 legal white moves', () {
      final game = ChessGame();

      var pieces = 0;
      for (var s = 0; s < 64; s++) {
        if (game.pieceAt(s) != null) pieces++;
      }
      expect(pieces, 32);
      expect(game.turn, PieceColor.white);
      expect(game.legalMoves().length, 20);
    });

    test('a pawn can step one or two from its start row, then only one', () {
      final game = ChessGame();
      final e2 = sq(6, 4);

      expect(game.legalMovesFrom(e2).map((m) => m.to),
          containsAll([sq(5, 4), sq(4, 4)]));

      game.play(moveTo(game, e2, sq(4, 4))); // e4
      game.play(moveTo(game, sq(1, 0), sq(2, 0))); // a6
      expect(game.legalMovesFrom(sq(4, 4)).map((m) => m.to), [sq(3, 4)]);
    });

    test('a knight jumps in an L and over pieces', () {
      final game = ChessGame();
      final g1 = sq(7, 6);

      expect(game.legalMovesFrom(g1).map((m) => m.to).toSet(),
          {sq(5, 5), sq(5, 7)});
    });

    test('capturing returns the captured piece and removes it', () {
      final game = ChessGame.custom({
        sq(4, 4): const ChessPiece(PieceColor.white, PieceType.rook),
        sq(4, 0): const ChessPiece(PieceColor.black, PieceType.knight),
        sq(7, 7): const ChessPiece(PieceColor.white, PieceType.king),
        sq(0, 7): const ChessPiece(PieceColor.black, PieceType.king),
      });

      final captured = game.play(moveTo(game, sq(4, 4), sq(4, 0)));

      expect(captured?.type, PieceType.knight);
      expect(game.pieceAt(sq(4, 0))?.type, PieceType.rook);
    });

    test('turns alternate and moving out of turn is impossible', () {
      final game = ChessGame();

      // Black pieces offer no moves while it's white's turn.
      expect(game.legalMovesFrom(sq(1, 4)), isEmpty);
      game.play(moveTo(game, sq(6, 4), sq(4, 4)));
      expect(game.turn, PieceColor.black);
      expect(game.legalMovesFrom(sq(6, 3)), isEmpty);
    });
  });

  group('ChessGame — check rules', () {
    test('a pinned piece may not expose its own king', () {
      final game = ChessGame.custom({
        sq(7, 4): const ChessPiece(PieceColor.white, PieceType.king),
        sq(6, 4): const ChessPiece(PieceColor.white, PieceType.rook),
        sq(0, 4): const ChessPiece(PieceColor.black, PieceType.rook),
        sq(0, 0): const ChessPiece(PieceColor.black, PieceType.king),
      });

      final targets = game.legalMovesFrom(sq(6, 4)).map((m) => m.to);
      // The pinned rook may only slide along the e-file.
      expect(targets, isNotEmpty);
      for (final target in targets) {
        expect(target % 8, 4);
      }
    });

    test('while in check, only check-resolving moves are legal', () {
      final game = ChessGame.custom({
        sq(7, 4): const ChessPiece(PieceColor.white, PieceType.king),
        sq(0, 4): const ChessPiece(PieceColor.black, PieceType.rook),
        sq(0, 0): const ChessPiece(PieceColor.black, PieceType.king),
      });

      expect(game.isInCheck(PieceColor.white), isTrue);
      expect(game.status, ChessStatus.check);
      for (final move in game.legalMoves()) {
        expect(move.to % 8, isNot(4),
            reason: 'king must step off the attacked file');
      }
    });

    test("fool's mate is detected as checkmate", () {
      final game = ChessGame();
      game.play(moveTo(game, sq(6, 5), sq(5, 5))); // f3
      game.play(moveTo(game, sq(1, 4), sq(3, 4))); // e5
      game.play(moveTo(game, sq(6, 6), sq(4, 6))); // g4
      game.play(moveTo(game, sq(0, 3), sq(4, 7))); // Qh4#

      expect(game.status, ChessStatus.checkmate);
      expect(game.isInCheck(PieceColor.white), isTrue);
      expect(game.legalMoves(), isEmpty);
    });

    test('a cornered king with no legal move but no check is stalemate', () {
      final game = ChessGame.custom({
        sq(0, 0): const ChessPiece(PieceColor.black, PieceType.king),
        sq(1, 2): const ChessPiece(PieceColor.white, PieceType.queen),
        sq(2, 1): const ChessPiece(PieceColor.white, PieceType.king),
      }, turn: PieceColor.black);

      expect(game.isInCheck(PieceColor.black), isFalse);
      expect(game.status, ChessStatus.stalemate);
    });

    test('bare kings (and king + one minor) are an instant draw', () {
      final bareKings = ChessGame.custom({
        sq(7, 4): const ChessPiece(PieceColor.white, PieceType.king),
        sq(0, 4): const ChessPiece(PieceColor.black, PieceType.king),
      });
      final kingAndKnight = ChessGame.custom({
        sq(7, 4): const ChessPiece(PieceColor.white, PieceType.king),
        sq(5, 4): const ChessPiece(PieceColor.white, PieceType.knight),
        sq(0, 4): const ChessPiece(PieceColor.black, PieceType.king),
      });
      final kingAndRook = ChessGame.custom({
        sq(7, 4): const ChessPiece(PieceColor.white, PieceType.king),
        sq(5, 4): const ChessPiece(PieceColor.white, PieceType.rook),
        sq(0, 4): const ChessPiece(PieceColor.black, PieceType.king),
      });

      expect(bareKings.status, ChessStatus.draw);
      expect(kingAndKnight.status, ChessStatus.draw);
      expect(kingAndRook.status, ChessStatus.playing);
    });
  });

  group('ChessGame — special moves', () {
    test('kingside castling moves king and rook together', () {
      final game = ChessGame.custom({
        sq(7, 4): const ChessPiece(PieceColor.white, PieceType.king),
        sq(7, 7): const ChessPiece(PieceColor.white, PieceType.rook),
        sq(0, 4): const ChessPiece(PieceColor.black, PieceType.king),
      });

      final castle = game
          .legalMovesFrom(sq(7, 4))
          .firstWhere((m) => m.isCastle, orElse: () => const ChessMove(0, 0));
      expect(castle.to, sq(7, 6));

      game.play(castle);
      expect(game.pieceAt(sq(7, 6))?.type, PieceType.king);
      expect(game.pieceAt(sq(7, 5))?.type, PieceType.rook);
    });

    test('castling is refused through an attacked square', () {
      final game = ChessGame.custom({
        sq(7, 4): const ChessPiece(PieceColor.white, PieceType.king),
        sq(7, 7): const ChessPiece(PieceColor.white, PieceType.rook),
        sq(0, 5): const ChessPiece(PieceColor.black, PieceType.rook),
        sq(0, 0): const ChessPiece(PieceColor.black, PieceType.king),
      });

      expect(game.legalMovesFrom(sq(7, 4)).where((m) => m.isCastle), isEmpty);
    });

    test('en passant captures the just-passed pawn', () {
      final game = ChessGame.custom({
        sq(3, 4): const ChessPiece(PieceColor.white, PieceType.pawn), // e5
        sq(1, 3): const ChessPiece(PieceColor.black, PieceType.pawn), // d7
        sq(7, 4): const ChessPiece(PieceColor.white, PieceType.king),
        sq(0, 4): const ChessPiece(PieceColor.black, PieceType.king),
      }, turn: PieceColor.black);

      game.play(moveTo(game, sq(1, 3), sq(3, 3))); // d5, passing e5

      final enPassant = game
          .legalMovesFrom(sq(3, 4))
          .firstWhere((m) => m.isEnPassant);
      expect(enPassant.to, sq(2, 3)); // d6

      game.play(enPassant);
      expect(game.pieceAt(sq(3, 3)), isNull, reason: 'passed pawn captured');
      expect(game.pieceAt(sq(2, 3))?.type, PieceType.pawn);
    });

    test('en passant is only available immediately', () {
      final game = ChessGame.custom({
        sq(3, 4): const ChessPiece(PieceColor.white, PieceType.pawn),
        sq(1, 3): const ChessPiece(PieceColor.black, PieceType.pawn),
        sq(7, 4): const ChessPiece(PieceColor.white, PieceType.king),
        sq(0, 4): const ChessPiece(PieceColor.black, PieceType.king),
      }, turn: PieceColor.black);
      game.play(moveTo(game, sq(1, 3), sq(3, 3))); // d5

      // White plays something else; the window closes.
      game.play(moveTo(game, sq(7, 4), sq(7, 3)));
      game.play(moveTo(game, sq(0, 4), sq(0, 3)));
      expect(game.legalMovesFrom(sq(3, 4)).where((m) => m.isEnPassant),
          isEmpty);
    });

    test('a pawn reaching the last rank becomes a queen', () {
      final game = ChessGame.custom({
        sq(1, 0): const ChessPiece(PieceColor.white, PieceType.pawn), // a7
        sq(7, 4): const ChessPiece(PieceColor.white, PieceType.king),
        sq(0, 4): const ChessPiece(PieceColor.black, PieceType.king),
      });

      final promotion = moveTo(game, sq(1, 0), sq(0, 0));
      expect(promotion.promotesToQueen, isTrue);
      game.play(promotion);
      expect(game.pieceAt(sq(0, 0))?.type, PieceType.queen);
    });
  });

  group('ChessGame — undo', () {
    test('undo restores the position, the turn, and special state', () {
      final game = ChessGame();
      game.play(moveTo(game, sq(6, 4), sq(4, 4))); // e4

      game.undo();

      expect(game.pieceAt(sq(6, 4))?.type, PieceType.pawn);
      expect(game.pieceAt(sq(4, 4)), isNull);
      expect(game.turn, PieceColor.white);
      expect(game.movesPlayed, 0);
      expect(game.legalMoves().length, 20);
    });

    test('undo restores a captured piece', () {
      final game = ChessGame.custom({
        sq(4, 4): const ChessPiece(PieceColor.white, PieceType.rook),
        sq(4, 0): const ChessPiece(PieceColor.black, PieceType.knight),
        sq(7, 7): const ChessPiece(PieceColor.white, PieceType.king),
        sq(0, 7): const ChessPiece(PieceColor.black, PieceType.king),
      });
      game.play(moveTo(game, sq(4, 4), sq(4, 0)));

      game.undo();

      expect(game.pieceAt(sq(4, 0))?.type, PieceType.knight);
      expect(game.pieceAt(sq(4, 4))?.type, PieceType.rook);
    });
  });
}
