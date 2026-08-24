import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/chess/chess_ai.dart';
import 'package:super_kid_adventure/game/chess/chess_game.dart';
import 'package:super_kid_adventure/game/chess/chess_models.dart';

void main() {
  int sq(int r, int c) => r * 8 + c;

  group('ChessAi', () {
    test('every level always returns a legal move', () {
      for (var level = 1; level <= 3; level++) {
        final game = ChessGame();
        final ai = ChessAi(random: Random(level));
        for (var ply = 0; ply < 10; ply++) {
          final legal = game.legalMoves();
          final move = ai.pickMove(game, level);
          expect(legal, contains(move),
              reason: 'level $level produced an illegal move');
          game.play(move!);
        }
      }
    });

    test('level 2 grabs the biggest free capture', () {
      final game = ChessGame.custom({
        sq(7, 0): const ChessPiece(PieceColor.white, PieceType.rook),
        sq(0, 0): const ChessPiece(PieceColor.black, PieceType.queen),
        sq(7, 4): const ChessPiece(PieceColor.white, PieceType.king),
        sq(0, 4): const ChessPiece(PieceColor.black, PieceType.king),
      });

      final move = ChessAi(random: Random(1)).pickMove(game, 2);

      expect(move, const ChessMove(56, 0));
    });

    test('level 3 finds a mate in one', () {
      final game = ChessGame.custom({
        sq(0, 6): const ChessPiece(PieceColor.black, PieceType.king),
        sq(1, 5): const ChessPiece(PieceColor.black, PieceType.pawn),
        sq(1, 6): const ChessPiece(PieceColor.black, PieceType.pawn),
        sq(1, 7): const ChessPiece(PieceColor.black, PieceType.pawn),
        sq(4, 0): const ChessPiece(PieceColor.white, PieceType.rook),
        sq(7, 6): const ChessPiece(PieceColor.white, PieceType.king),
      });

      final move = ChessAi(random: Random(1)).pickMove(game, 3);

      game.play(move!);
      expect(game.status, ChessStatus.checkmate);
    });

    test('the hint suggestion is always a legal move', () {
      final game = ChessGame();
      final suggestion = ChessAi(random: Random(2)).suggestMove(game);

      expect(game.legalMoves(), contains(suggestion));
    });

    test('a finished game yields no move', () {
      final game = ChessGame.custom({
        sq(0, 0): const ChessPiece(PieceColor.black, PieceType.king),
        sq(1, 2): const ChessPiece(PieceColor.white, PieceType.queen),
        sq(2, 1): const ChessPiece(PieceColor.white, PieceType.king),
      }, turn: PieceColor.black);

      expect(ChessAi().pickMove(game, 1), isNull);
    });
  });
}
