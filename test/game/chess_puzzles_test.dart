import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/chess/chess_game.dart';
import 'package:super_kid_adventure/game/chess/chess_models.dart';
import 'package:super_kid_adventure/game/data/chess_puzzles.dart';

void main() {
  group('ChessPuzzles content', () {
    test('puzzle ids are unique', () {
      final ids = ChessPuzzles.all.map((p) => p.id).toList();

      expect(ids.toSet().length, ids.length);
    });

    test('every puzzle is solvable in one white move, judged by the engine',
        () {
      for (final puzzle in ChessPuzzles.all) {
        final game = ChessGame.custom(Map.of(puzzle.pieces));
        expect(game.turn, PieceColor.white);

        var solvable = false;
        for (final move in game.legalMoves()) {
          final captured = game.play(move);
          final achieved = switch (puzzle.goal) {
            ChessPuzzleGoal.capture => captured != null,
            ChessPuzzleGoal.check => game.isInCheck(PieceColor.black),
            ChessPuzzleGoal.checkmate => game.status == ChessStatus.checkmate,
          };
          game.undo();
          if (achieved) {
            solvable = true;
            break;
          }
        }
        expect(solvable, isTrue,
            reason: 'Puzzle ${puzzle.id} cannot be solved in one move');
      }
    });

    test('every puzzle position is playable (not already over)', () {
      for (final puzzle in ChessPuzzles.all) {
        final game = ChessGame.custom(Map.of(puzzle.pieces));

        expect(game.legalMoves(), isNotEmpty,
            reason: 'Puzzle ${puzzle.id} starts with no moves');
        expect(game.isInCheck(PieceColor.black), isFalse,
            reason: 'Puzzle ${puzzle.id} starts with black already in check');
      }
    });
  });
}
