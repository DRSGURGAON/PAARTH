import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/mini_games/math_dash_screen.dart';
import 'package:super_kid_adventure/game/data/companion_catalog.dart';
import 'package:super_kid_adventure/game/repositories/companion_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';
import 'package:super_kid_adventure/shared/widgets/shake_widget.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;

  Future<Widget> buildHarness({bool robotEquipped = false}) async {
    storage = FakeLocalStorageService();
    if (robotEquipped) {
      await CompanionRepository(storage).selectCompanion(CompanionIds.robot);
    }
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const MathDashScreen(),
      ),
    );
  }

  /// Reads the live screen state to find the current correct option —
  /// questions are generated, so tests can't hard-code answers.
  MathDashScreenState stateOf(WidgetTester tester) =>
      tester.state<MathDashScreenState>(find.byType(MathDashScreen));

  Future<void> answerCorrectly(WidgetTester tester) async {
    final correctIndex = stateOf(tester).currentChallenge.correctIndex;
    await tester.tap(find.byKey(ValueKey('option_$correctIndex')));
    await tester.pumpAndSettle();
  }

  Future<void> answerWrongOnce(WidgetTester tester) async {
    final challenge = stateOf(tester).currentChallenge;
    final wrongIndex =
        (challenge.correctIndex + 1) % challenge.options.length;
    await tester.tap(find.byKey(ValueKey('option_$wrongIndex')));
    await tester.pumpAndSettle();
  }

  testWidgets('a perfect round scores 8/8 and earns a star', (tester) async {
    await tester.pumpWidget(await buildHarness());

    // Intro states the predictable reward, then start.
    expect(find.textContaining('earn a ⭐'), findsOneWidget);
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    for (var i = 0; i < MathDashScreen.roundLength; i++) {
      expect(
        find.text('Question ${i + 1} of ${MathDashScreen.roundLength}'),
        findsOneWidget,
      );
      await answerCorrectly(tester);
    }

    expect(
      find.text('You got ${MathDashScreen.roundLength} '
          'of ${MathDashScreen.roundLength}!'),
      findsOneWidget,
    );
    expect(find.textContaining('+1 ⭐'), findsOneWidget);
    expect(ProgressRepository(storage).stars, 1);
  });

  testWidgets('wrong first tries cost score; below threshold earns no star',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    // Miss the first try on 3 questions -> best possible score is 5.
    for (var i = 0; i < MathDashScreen.roundLength; i++) {
      if (i < 3) {
        await answerWrongOnce(tester);
        // Gentle encouragement, then the retry succeeds.
        expect(find.textContaining('!'), findsWidgets);
        await answerCorrectly(tester);
      } else {
        await answerCorrectly(tester);
      }
    }

    expect(
      find.text('You got 5 of ${MathDashScreen.roundLength}!'),
      findsOneWidget,
    );
    expect(find.textContaining('Great effort!'), findsOneWidget);
    expect(ProgressRepository(storage).stars, 0);
  });

  testWidgets('Play Again starts a fresh round', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    for (var i = 0; i < MathDashScreen.roundLength; i++) {
      await answerCorrectly(tester);
    }

    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();

    expect(
      find.text('Question 1 of ${MathDashScreen.roundLength}'),
      findsOneWidget,
    );
  });

  testWidgets("Robot's hint crosses out one wrong option, once per question",
      (tester) async {
    await tester.pumpWidget(await buildHarness(robotEquipped: true));
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('robot_hint_button')), findsOneWidget);
    expect(stateOf(tester).eliminatedOptions, isEmpty);

    await tester.tap(find.byKey(const ValueKey('robot_hint_button')));
    await tester.pumpAndSettle();

    // Exactly one wrong option eliminated; the correct one is untouched.
    final correctIndex = stateOf(tester).currentChallenge.correctIndex;
    expect(stateOf(tester).eliminatedOptions.length, 1);
    expect(stateOf(tester).eliminatedOptions.contains(correctIndex), isFalse);
    // Hint button disappears once used for this question.
    expect(find.byKey(const ValueKey('robot_hint_button')), findsNothing);

    // The eliminated option's button is disabled but the round is still
    // winnable via the correct answer.
    await answerCorrectly(tester);
    expect(find.text('Question 2 of ${MathDashScreen.roundLength}'),
        findsOneWidget);
    // A fresh hint is offered again on the new question.
    expect(find.byKey(const ValueKey('robot_hint_button')), findsOneWidget);
  });

  testWidgets('a wrong answer actually plays the shake animation',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    final challenge = stateOf(tester).currentChallenge;
    final wrongIndex = (challenge.correctIndex + 1) % challenge.options.length;
    await tester.tap(find.byKey(ValueKey('option_$wrongIndex')));
    await tester.pump(const Duration(milliseconds: 80));

    final shakeState =
        tester.state<ShakeWidgetState>(find.byType(ShakeWidget));
    expect(shakeState.offset.value, isNot(0));

    await tester.pumpAndSettle();
    expect(shakeState.offset.value, 0);
  });

  testWidgets('without Robot equipped, no hint button is offered',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('robot_hint_button')), findsNothing);
  });
}
