import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/mini_games/math_dash_screen.dart';
import 'package:super_kid_adventure/game/data/companion_catalog.dart';
import 'package:super_kid_adventure/game/models/mini_game_result.dart';
import 'package:super_kid_adventure/game/repositories/coin_repository.dart';
import 'package:super_kid_adventure/game/repositories/companion_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';
import 'package:super_kid_adventure/game/systems/quest_reward_service.dart';
import 'package:super_kid_adventure/shared/widgets/shake_widget.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;
  const total = MathDashScreen.defaultSessionLength;

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
    final correctIndex = stateOf(tester).currentQuestion.correctIndex;
    await tester.tap(find.byKey(ValueKey('option_$correctIndex')));
    await tester.pumpAndSettle();
  }

  Future<void> answerWrongOnce(WidgetTester tester) async {
    final question = stateOf(tester).currentQuestion;
    final wrongIndex =
        (question.correctIndex + 1) % question.options.length;
    await tester.tap(find.byKey(ValueKey('option_$wrongIndex')));
    await tester.pumpAndSettle();
  }

  testWidgets('a perfect session earns the star plus the perfect-streak '
      'coin bonus', (tester) async {
    await tester.pumpWidget(await buildHarness());

    // Intro states the predictable reward, then start.
    expect(find.textContaining('earn a ⭐'), findsOneWidget);
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    for (var i = 0; i < total; i++) {
      expect(find.text('${i + 1} / $total'), findsOneWidget);
      await answerCorrectly(tester);
    }

    expect(find.text('You got $total of $total!'), findsOneWidget);
    expect(find.text('🔥 Best streak: $total in a row'), findsOneWidget);
    final expected = QuestRewardService.calculateMiniGameSession(
        correctAnswers: total, totalQuestions: total, bestStreak: total);
    expect(find.textContaining('+${expected.stars} ⭐'), findsOneWidget);
    expect(ProgressRepository(storage).stars, expected.stars);
    expect(CoinRepository(storage).coins, expected.coins);
  });

  testWidgets('the streak counter appears from 2 in a row and resets on a '
      'miss without touching earned progress', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    // No streak chip on the first question.
    expect(find.textContaining('🔥'), findsNothing);
    await answerCorrectly(tester);
    await answerCorrectly(tester);
    expect(find.text('🔥 2'), findsOneWidget);

    // A miss resets the streak chip — and shows a hint, never shame.
    await answerWrongOnce(tester);
    expect(find.textContaining('💡'), findsOneWidget);
    await answerCorrectly(tester); // retry succeeds, no first-try credit
    expect(find.textContaining('🔥'), findsNothing);
    expect(find.text('⭐ 2'), findsOneWidget); // score kept, nothing removed
  });

  testWidgets('wrong first tries cost score; below threshold earns no star',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    // Miss the first try on questions 1 and 4 -> score 3, best streak 2
    // -> below the 4-of-5 star threshold and no streak bonus.
    for (var i = 0; i < total; i++) {
      if (i == 0 || i == 3) {
        await answerWrongOnce(tester);
        // Gentle encouragement plus a hint, then the retry succeeds.
        expect(find.textContaining('💡'), findsOneWidget);
        await answerCorrectly(tester);
      } else {
        await answerCorrectly(tester);
      }
    }

    expect(find.text('You got 3 of $total!'), findsOneWidget);
    expect(find.textContaining('Great effort!'), findsOneWidget);
    expect(ProgressRepository(storage).stars, 0);
    expect(CoinRepository(storage).coins, 0);
  });

  testWidgets('Play Again starts a fresh session', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    for (var i = 0; i < total; i++) {
      await answerCorrectly(tester);
    }

    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();

    expect(find.text('1 / $total'), findsOneWidget);
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
                popped = await Navigator.of(context).push<MiniGameSessionResult>(
                  MaterialPageRoute(
                    builder: (_) =>
                        const MathDashScreen(embedded: true, sessionLength: 3),
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
    await tester.pumpAndSettle();

    // Straight into question 1 — no "Let's Go!" intro.
    expect(find.text("Let's Go!"), findsNothing);
    expect(find.text('1 / 3'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await answerCorrectly(tester);
    }

    expect(popped, isNotNull);
    expect(popped!.completed, isTrue);
    expect(popped!.correctAnswers, 3);
    expect(popped!.totalQuestions, 3);
    // The quest pays the reward, not the embedded session.
    expect(popped!.starsAwarded, 0);
    expect(ProgressRepository(storage).stars, 0);
    expect(CoinRepository(storage).coins, 0);
  });

  testWidgets("Robot's help crosses out one wrong option, once per question",
      (tester) async {
    await tester.pumpWidget(await buildHarness(robotEquipped: true));
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('robot_hint_button')), findsOneWidget);
    expect(stateOf(tester).eliminatedOptions, isEmpty);

    await tester.tap(find.byKey(const ValueKey('robot_hint_button')));
    await tester.pumpAndSettle();

    // Exactly one wrong option eliminated; the correct one is untouched.
    final correctIndex = stateOf(tester).currentQuestion.correctIndex;
    expect(stateOf(tester).eliminatedOptions.length, 1);
    expect(stateOf(tester).eliminatedOptions.contains(correctIndex), isFalse);
    // Help button disappears once used for this question.
    expect(find.byKey(const ValueKey('robot_hint_button')), findsNothing);

    // The eliminated option's button is disabled but the session is
    // still winnable via the correct answer.
    await answerCorrectly(tester);
    expect(find.text('2 / $total'), findsOneWidget);
    // Fresh help is offered again on the new question.
    expect(find.byKey(const ValueKey('robot_hint_button')), findsOneWidget);
  });

  testWidgets('a wrong answer actually plays the shake animation',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    final question = stateOf(tester).currentQuestion;
    final wrongIndex = (question.correctIndex + 1) % question.options.length;
    await tester.tap(find.byKey(ValueKey('option_$wrongIndex')));
    await tester.pump(const Duration(milliseconds: 80));

    final shakeState =
        tester.state<ShakeWidgetState>(find.byType(ShakeWidget));
    expect(shakeState.offset.value, isNot(0));

    await tester.pumpAndSettle();
    expect(shakeState.offset.value, 0);
  });

  testWidgets('without Robot equipped, no help button is offered',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('robot_hint_button')), findsNothing);
  });
}
