import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/mini_games/memory_master_screen.dart';
import 'package:super_kid_adventure/game/data/companion_catalog.dart';
import 'package:super_kid_adventure/game/models/mini_game_result.dart';
import 'package:super_kid_adventure/game/repositories/coin_repository.dart';
import 'package:super_kid_adventure/game/repositories/companion_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';
import 'package:super_kid_adventure/game/systems/quest_reward_service.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;
  const total = MemoryMasterScreen.defaultSessionLength;

  Future<Widget> buildHarness({bool pandaEquipped = false}) async {
    storage = FakeLocalStorageService();
    if (pandaEquipped) {
      await CompanionRepository(storage).selectCompanion(CompanionIds.panda);
    }
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const MemoryMasterScreen(),
      ),
    );
  }

  MemoryMasterScreenState stateOf(WidgetTester tester) =>
      tester.state<MemoryMasterScreenState>(find.byType(MemoryMasterScreen));

  /// Waits out the current round's study phase (duration varies with
  /// item count, so it's read from live state).
  Future<void> waitOutStudy(WidgetTester tester) async {
    await tester.pump(
        stateOf(tester).currentStudyDuration + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
  }

  Future<void> waitThenAnswerCorrectly(WidgetTester tester) async {
    await waitOutStudy(tester);
    final correctIndex = stateOf(tester).currentRound.question.correctIndex;
    await tester.tap(find.byKey(ValueKey('option_$correctIndex')));
    await tester.pumpAndSettle();
  }

  Future<void> answerWrongOnce(WidgetTester tester) async {
    final question = stateOf(tester).currentRound.question;
    final wrongIndex = (question.correctIndex + 1) % question.options.length;
    await tester.tap(find.byKey(ValueKey('option_$wrongIndex')));
    await tester.pumpAndSettle();
  }

  testWidgets('a perfect session earns the star plus the perfect-streak '
      'coin bonus', (tester) async {
    await tester.pumpWidget(await buildHarness());

    expect(find.textContaining('earn a ⭐'), findsOneWidget);
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    // First round starts in the studying phase, jungle scene visible.
    expect(find.text('👀 Watch carefully!'), findsOneWidget);
    expect(stateOf(tester).currentRound.placements, isNotEmpty);

    for (var i = 0; i < total; i++) {
      expect(find.text('${i + 1} / $total'), findsOneWidget);
      await waitThenAnswerCorrectly(tester);
    }

    expect(find.text('You got $total of $total!'), findsOneWidget);
    expect(find.text('🧠 Best streak: $total remembered in a row'),
        findsOneWidget);
    final expected = QuestRewardService.calculateMiniGameSession(
        correctAnswers: total, totalQuestions: total, bestStreak: total);
    expect(find.textContaining('+${expected.stars} ⭐'), findsOneWidget);
    expect(ProgressRepository(storage).stars, expected.stars);
    expect(CoinRepository(storage).coins, expected.coins);
  });

  testWidgets('items are hidden once the answering phase begins',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    final round = stateOf(tester).currentRound;
    await waitOutStudy(tester);

    expect(find.text('👀 Watch carefully!'), findsNothing);
    expect(find.text(round.question.prompt), findsOneWidget);
  });

  testWidgets('a miss offers a once-per-round Look Again peek, then the '
      'retry still works', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    await waitOutStudy(tester);
    final question = stateOf(tester).currentRound.question;
    await answerWrongOnce(tester);

    // Gentle encouragement plus the memory hint: another look.
    expect(find.textContaining('!'), findsWidgets);
    expect(find.byKey(const ValueKey('look_again_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('look_again_button')));
    await tester.pump();
    // Back in the (shorter) study phase, same round.
    expect(find.text('👀 Watch carefully!'), findsOneWidget);
    await waitOutStudy(tester);

    // Same question returns; the peek is one-per-round.
    expect(find.text(question.prompt), findsOneWidget);
    expect(find.byKey(const ValueKey('look_again_button')), findsNothing);

    await tester.tap(find.byKey(ValueKey('option_${question.correctIndex}')));
    await tester.pumpAndSettle();
    expect(find.text('2 / $total'), findsOneWidget);
  });

  testWidgets('the streak chip appears from 2 in a row and resets on a miss',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    expect(find.textContaining('🧠'), findsNothing);
    await waitThenAnswerCorrectly(tester);
    await waitThenAnswerCorrectly(tester);
    expect(find.text('🧠 2'), findsOneWidget);

    await waitOutStudy(tester);
    await answerWrongOnce(tester);
    final correctIndex = stateOf(tester).currentRound.question.correctIndex;
    await tester.tap(find.byKey(ValueKey('option_$correctIndex')));
    await tester.pumpAndSettle();
    expect(find.textContaining('🧠'), findsNothing);
    expect(find.text('⭐ 2'), findsOneWidget); // score kept, nothing removed
  });

  testWidgets('an embedded session skips the intro and pops a completed '
      'result without paying rewards itself', (tester) async {
    storage = FakeLocalStorageService();
    MiniGameSessionResult? popped;
    await tester.pumpWidget(AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () async {
                popped =
                    await Navigator.of(context).push<MiniGameSessionResult>(
                  MaterialPageRoute(
                    builder: (_) => const MemoryMasterScreen(
                        embedded: true, sessionLength: 3),
                  ),
                );
              },
              child: const Text('launch'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('launch'));
    await tester.pump();

    // Straight into round 1's study phase — no intro.
    expect(find.text("Let's Go!"), findsNothing);
    expect(find.text('👀 Watch carefully!'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await waitThenAnswerCorrectly(tester);
    }

    expect(popped, isNotNull);
    expect(popped!.completed, isTrue);
    expect(popped!.correctAnswers, 3);
    expect(popped!.totalQuestions, 3);
    expect(popped!.starsAwarded, 0);
    expect(ProgressRepository(storage).stars, 0);
    expect(CoinRepository(storage).coins, 0);
  });

  testWidgets('Panda gives 1.5x study time and is announced during study',
      (tester) async {
    await tester.pumpWidget(await buildHarness(pandaEquipped: true));
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    expect(find.byKey(const ValueKey('panda_hint_label')), findsOneWidget);

    final baseDuration = stateOf(tester).currentRound.studyDuration;
    final actualDuration = stateOf(tester).currentStudyDuration;
    expect(
      actualDuration.inMicroseconds,
      (baseDuration.inMicroseconds * 3) ~/ 2,
    );

    // The un-boosted duration alone should NOT be enough to leave the
    // studying phase yet — Panda's extra time is genuinely in effect.
    await tester.pump(baseDuration + const Duration(milliseconds: 10));
    expect(find.text('👀 Watch carefully!'), findsOneWidget);

    // But waiting out the full boosted duration does move on.
    await tester.pump(actualDuration - baseDuration);
    await tester.pumpAndSettle();
    expect(find.text('👀 Watch carefully!'), findsNothing);
  });

  testWidgets('without Panda equipped, study time is the base duration',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    expect(find.byKey(const ValueKey('panda_hint_label')), findsNothing);
    expect(
      stateOf(tester).currentStudyDuration,
      stateOf(tester).currentRound.studyDuration,
    );
  });
}
