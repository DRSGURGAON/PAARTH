import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/activities/chess/chess_play_screen.dart';
import 'package:super_kid_adventure/game/chess/chess_game.dart';
import 'package:super_kid_adventure/game/chess/chess_models.dart';
import 'package:super_kid_adventure/game/models/activity_progress.dart';
import 'package:super_kid_adventure/game/repositories/activity_progress_repository.dart';
import 'package:super_kid_adventure/game/repositories/coin_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;
  const aiDelay = Duration(milliseconds: 100);

  int sq(int r, int c) => r * 8 + c;

  Widget buildHarness({ChessGame? initialGame}) {
    storage = FakeLocalStorageService();
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: ChessPlayScreen(
          level: 1,
          random: Random(3),
          aiDelay: aiDelay,
          initialGame: initialGame,
        ),
      ),
    );
  }

  ChessPlayScreenState stateOf(WidgetTester tester) =>
      tester.state<ChessPlayScreenState>(find.byType(ChessPlayScreen));

  Future<void> playPawnAndAiReply(WidgetTester tester) async {
    await tester.tap(find.byKey(ValueKey('square_${sq(6, 4)}'))); // e2
    await tester.pump();
    await tester.tap(find.byKey(ValueKey('square_${sq(4, 4)}'))); // e4
    await tester.pump();
    expect(stateOf(tester).game.movesPlayed, 1);
    await tester.pump(aiDelay + const Duration(milliseconds: 20));
    await tester.pumpAndSettle();
  }

  testWidgets('tap a piece, tap a highlighted square — the move plays and '
      'the AI answers', (tester) async {
    await tester.pumpWidget(buildHarness());

    expect(find.textContaining('Your move'), findsOneWidget);
    await playPawnAndAiReply(tester);

    final game = stateOf(tester).game;
    expect(game.pieceAt(sq(4, 4))?.type, PieceType.pawn);
    expect(game.movesPlayed, 2, reason: 'the AI replied');
    expect(game.turn, PieceColor.white);
  });

  testWidgets('tapping a black piece selects nothing for the child',
      (tester) async {
    await tester.pumpWidget(buildHarness());

    await tester.tap(find.byKey(ValueKey('square_${sq(1, 4)}')));
    await tester.pump();
    // No legal move exists to e5 without a selection — board unchanged.
    await tester.tap(find.byKey(ValueKey('square_${sq(3, 4)}')));
    await tester.pump();

    expect(stateOf(tester).game.movesPlayed, 0);
  });

  testWidgets('the hint button suggests a real move', (tester) async {
    await tester.pumpWidget(buildHarness());

    await tester.tap(find.byKey(const ValueKey('chess_hint_button')));
    await tester.pump();

    expect(find.textContaining('💡 Try moving your'), findsOneWidget);
  });

  testWidgets('undo takes back the AI reply and the child\'s own move',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    await playPawnAndAiReply(tester);

    await tester.tap(find.byKey(const ValueKey('chess_undo_button')));
    await tester.pump();

    final game = stateOf(tester).game;
    expect(game.movesPlayed, 0);
    expect(game.turn, PieceColor.white);
  });

  testWidgets('restart clears the board back to the start', (tester) async {
    await tester.pumpWidget(buildHarness());
    await playPawnAndAiReply(tester);

    await tester.tap(find.byKey(const ValueKey('chess_restart_button')));
    await tester.pump();

    expect(stateOf(tester).game.movesPlayed, 0);
    expect(stateOf(tester).game.pieceAt(sq(6, 4))?.type, PieceType.pawn);
  });

  testWidgets('delivering checkmate pays the win reward and records the '
      'match', (tester) async {
    // Mate in one for white: Qd6→e7 supported by Ke6.
    await tester.pumpWidget(buildHarness(
      initialGame: ChessGame.custom({
        sq(0, 4): const ChessPiece(PieceColor.black, PieceType.king),
        sq(2, 3): const ChessPiece(PieceColor.white, PieceType.queen),
        sq(2, 4): const ChessPiece(PieceColor.white, PieceType.king),
      }),
    ));

    await tester.tap(find.byKey(ValueKey('square_${sq(2, 3)}'))); // queen
    await tester.pump();
    await tester.tap(find.byKey(ValueKey('square_${sq(1, 4)}'))); // e7#
    await tester.pumpAndSettle();

    expect(find.textContaining('you win'), findsOneWidget);
    expect(find.byKey(const ValueKey('chess_reward')), findsOneWidget);
    expect(find.textContaining('+3 ⭐'), findsOneWidget);
    expect(ProgressRepository(storage).stars, 3);
    expect(CoinRepository(storage).coins, 10);
    final progress =
        ActivityProgressRepository(storage).load(ActivityIds.chess);
    expect(progress.sessionsCompleted, 1);
    expect(progress.achievements,
        containsAll(['chess_first_game', 'chess_first_win']));

    // New Game resets everything for another round.
    await tester.tap(find.text('New Game'));
    await tester.pump();
    expect(stateOf(tester).game.movesPlayed, 0);
    expect(find.textContaining('Your move'), findsOneWidget);
  });
}
