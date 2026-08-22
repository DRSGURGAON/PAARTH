import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/mini_games/memory_master_screen.dart';
import 'package:super_kid_adventure/game/data/companion_catalog.dart';
import 'package:super_kid_adventure/game/repositories/companion_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;

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
  /// item count, so it's read from live state) then answers correctly.
  Future<void> waitThenAnswerCorrectly(WidgetTester tester) async {
    final round = stateOf(tester).currentRound;
    await tester.pump(round.studyDuration + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    final correctIndex = stateOf(tester).currentRound.question.correctIndex;
    await tester.tap(find.byKey(ValueKey('option_$correctIndex')));
    await tester.pumpAndSettle();
  }

  testWidgets('a perfect game scores 5/5 and earns a star', (tester) async {
    await tester.pumpWidget(await buildHarness());

    expect(find.textContaining('earn a ⭐'), findsOneWidget);
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    // First round starts in the studying phase.
    expect(find.text('Remember these!'), findsOneWidget);
    expect(stateOf(tester).currentRound.items, isNotEmpty);

    for (var i = 0; i < MemoryMasterScreen.roundLength; i++) {
      expect(
        find.text('Round ${i + 1} of ${MemoryMasterScreen.roundLength}'),
        findsOneWidget,
      );
      await waitThenAnswerCorrectly(tester);
    }

    expect(
      find.text('You got ${MemoryMasterScreen.roundLength} '
          'of ${MemoryMasterScreen.roundLength}!'),
      findsOneWidget,
    );
    expect(find.textContaining('+1 ⭐'), findsOneWidget);
    expect(ProgressRepository(storage).stars, 1);
  });

  testWidgets('items are hidden once the answering phase begins',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    final round = stateOf(tester).currentRound;
    await tester.pump(round.studyDuration + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Remember these!'), findsNothing);
    expect(find.text(round.question.prompt), findsOneWidget);
  });

  testWidgets('a wrong first try still allows a correct retry',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    final round = stateOf(tester).currentRound;
    await tester.pump(round.studyDuration + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    final question = round.question;
    final wrongIndex = (question.correctIndex + 1) % question.options.length;
    await tester.tap(find.byKey(ValueKey('option_$wrongIndex')));
    await tester.pumpAndSettle();

    expect(find.textContaining('!'), findsWidgets);
    await tester.tap(find.byKey(ValueKey('option_${question.correctIndex}')));
    await tester.pumpAndSettle();

    expect(find.text('Round 2 of ${MemoryMasterScreen.roundLength}'),
        findsOneWidget);
  });

  testWidgets("Panda gives 1.5x study time and is announced during study",
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
    expect(find.text('Remember these!'), findsOneWidget);

    // But waiting out the full boosted duration does move on.
    await tester.pump(actualDuration - baseDuration);
    await tester.pumpAndSettle();
    expect(find.text('Remember these!'), findsNothing);
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
