import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/navigation/app_router.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/parent_zone/parent_gate_screen.dart';
import 'package:super_kid_adventure/game/systems/parent_gate_challenge_generator.dart';
import 'package:super_kid_adventure/shared/widgets/shake_widget.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  Widget buildHarness({int seed = 1}) {
    return AppScope(
      storage: FakeLocalStorageService(),
      child: MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.generateRoute,
        home: ParentGateScreen(random: Random(seed)),
      ),
    );
  }

  ParentGateScreenState stateOf(WidgetTester tester) =>
      tester.state<ParentGateScreenState>(find.byType(ParentGateScreen));

  testWidgets('the correct answer opens the Parent Zone', (tester) async {
    await tester.pumpWidget(buildHarness());

    final answer = stateOf(tester).currentChallenge.answer;
    await tester.enterText(
      find.byKey(const ValueKey('parent_gate_input')),
      '$answer',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Parent Zone'), findsOneWidget);
  });

  testWidgets('a wrong answer shows an error and swaps in a new challenge',
      (tester) async {
    await tester.pumpWidget(buildHarness(seed: 5));

    // Same seed as the screen's, one step ahead, to know the challenge
    // that follows a wrong first attempt.
    final expectedGenerator = ParentGateChallengeGenerator(random: Random(5));
    final firstChallenge = expectedGenerator.next();
    final secondChallenge = expectedGenerator.next();
    expect(stateOf(tester).currentChallenge.a, firstChallenge.a);
    expect(stateOf(tester).currentChallenge.b, firstChallenge.b);

    await tester.enterText(
      find.byKey(const ValueKey('parent_gate_input')),
      '${firstChallenge.answer + 1}',
    );
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 80));

    // The wrong answer actually shakes the challenge, not just the text.
    final shakeState =
        tester.state<ShakeWidgetState>(find.byType(ShakeWidget));
    expect(shakeState.offset.value, isNot(0));

    await tester.pumpAndSettle();
    expect(shakeState.offset.value, 0);

    expect(find.text('Not quite — try again.'), findsOneWidget);
    // Still on the gate, not the Parent Zone.
    expect(find.text('Parent Zone'), findsNothing);
    expect(stateOf(tester).currentChallenge.a, secondChallenge.a);
    expect(stateOf(tester).currentChallenge.b, secondChallenge.b);

    // The input is cleared, ready for a fresh attempt.
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('parent_gate_input')),
    );
    expect(field.controller!.text, isEmpty);
  });

  testWidgets('an empty submission is treated as wrong, not a crash',
      (tester) async {
    await tester.pumpWidget(buildHarness());

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Not quite — try again.'), findsOneWidget);
  });
}
