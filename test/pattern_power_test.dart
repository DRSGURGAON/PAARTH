import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/mini_games/pattern_power_screen.dart';
import 'package:super_kid_adventure/game/data/companion_catalog.dart';
import 'package:super_kid_adventure/game/repositories/companion_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;

  Future<Widget> buildHarness({bool foxEquipped = false}) async {
    storage = FakeLocalStorageService();
    if (foxEquipped) {
      await CompanionRepository(storage).selectCompanion(CompanionIds.fox);
    }
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const PatternPowerScreen(),
      ),
    );
  }

  PatternPowerScreenState stateOf(WidgetTester tester) =>
      tester.state<PatternPowerScreenState>(find.byType(PatternPowerScreen));

  Future<void> answerCorrectly(WidgetTester tester) async {
    final correctIndex = stateOf(tester).currentChallenge.correctIndex;
    await tester.tap(find.byKey(ValueKey('option_$correctIndex')));
    await tester.pumpAndSettle();
  }

  testWidgets('a perfect round scores 8/8 and earns a star', (tester) async {
    await tester.pumpWidget(await buildHarness());

    expect(find.textContaining('earn a ⭐'), findsOneWidget);
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    for (var i = 0; i < PatternPowerScreen.roundLength; i++) {
      expect(
        find.text('Question ${i + 1} of ${PatternPowerScreen.roundLength}'),
        findsOneWidget,
      );
      // The challenge shows a visual pattern with the prompt.
      expect(find.text('What comes next?'), findsOneWidget);
      await answerCorrectly(tester);
    }

    expect(
      find.text('You got ${PatternPowerScreen.roundLength} '
          'of ${PatternPowerScreen.roundLength}!'),
      findsOneWidget,
    );
    expect(find.textContaining('+1 ⭐'), findsOneWidget);
    expect(ProgressRepository(storage).stars, 1);
  });

  testWidgets('a wrong first try still allows a correct retry',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    final challenge = stateOf(tester).currentChallenge;
    final wrongIndex =
        (challenge.correctIndex + 1) % challenge.options.length;
    await tester.tap(find.byKey(ValueKey('option_$wrongIndex')));
    await tester.pumpAndSettle();

    expect(find.textContaining('!'), findsWidgets);
    await answerCorrectly(tester);

    expect(find.text('Question 2 of ${PatternPowerScreen.roundLength}'),
        findsOneWidget);
  });

  testWidgets("Fox's hint crosses out one wrong option, once per question",
      (tester) async {
    await tester.pumpWidget(await buildHarness(foxEquipped: true));
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fox_hint_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('fox_hint_button')));
    await tester.pumpAndSettle();

    final correctIndex = stateOf(tester).currentChallenge.correctIndex;
    expect(stateOf(tester).eliminatedOptions.length, 1);
    expect(stateOf(tester).eliminatedOptions.contains(correctIndex), isFalse);
    expect(find.byKey(const ValueKey('fox_hint_button')), findsNothing);

    await answerCorrectly(tester);
    expect(find.text('Question 2 of ${PatternPowerScreen.roundLength}'),
        findsOneWidget);
    expect(find.byKey(const ValueKey('fox_hint_button')), findsOneWidget);
  });

  testWidgets('without Fox equipped, no hint button is offered',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fox_hint_button')), findsNothing);
  });
}
