import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/mini_games/pattern_power_screen.dart';
import 'package:super_kid_adventure/game/data/companion_catalog.dart';
import 'package:super_kid_adventure/game/models/mini_game_result.dart';
import 'package:super_kid_adventure/game/repositories/coin_repository.dart';
import 'package:super_kid_adventure/game/repositories/companion_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';
import 'package:super_kid_adventure/game/systems/quest_reward_service.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;
  const total = PatternPowerScreen.defaultSessionLength;

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
    final correctIndex = stateOf(tester).currentQuestion.correctIndex;
    await tester.tap(find.byKey(ValueKey('option_$correctIndex')));
    await tester.pumpAndSettle();
  }

  Future<void> answerWrongOnce(WidgetTester tester) async {
    final question = stateOf(tester).currentQuestion;
    final wrongIndex = (question.correctIndex + 1) % question.options.length;
    await tester.tap(find.byKey(ValueKey('option_$wrongIndex')));
    await tester.pumpAndSettle();
  }

  testWidgets('a perfect session earns the star plus the perfect-streak '
      'coin bonus, with the lock reacting to each solve', (tester) async {
    await tester.pumpWidget(await buildHarness());

    expect(find.textContaining('earn a ⭐'), findsOneWidget);
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    for (var i = 0; i < total; i++) {
      expect(find.text('${i + 1} / $total'), findsOneWidget);
      // The pattern sits inside the jungle lock card.
      expect(find.text('🔒'), findsOneWidget);
      await answerCorrectly(tester);
      if (i < total - 1) {
        // The lock visibly reacts after each solve.
        expect(find.byKey(const ValueKey('lock_opened_chip')), findsOneWidget);
      }
    }

    expect(find.text('You got $total of $total!'), findsOneWidget);
    expect(find.text('🧩 Best streak: $total solved in a row'),
        findsOneWidget);
    final expected = QuestRewardService.calculateMiniGameSession(
        correctAnswers: total, totalQuestions: total, bestStreak: total);
    expect(find.textContaining('+${expected.stars} ⭐'), findsOneWidget);
    expect(find.textContaining('The jungle lock opens!'), findsOneWidget);
    expect(ProgressRepository(storage).stars, expected.stars);
    expect(CoinRepository(storage).coins, expected.coins);
  });

  testWidgets('a miss shows encouragement plus the repeating-group hint, '
      'and the retry still works', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    final question = stateOf(tester).currentQuestion;
    await answerWrongOnce(tester);

    expect(find.textContaining('!'), findsWidgets);
    expect(find.textContaining('💡'), findsOneWidget);
    // Level-1 patterns are visual — the hint re-draws the row with
    // dividers marking the repeats.
    expect(find.textContaining('|'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('option_${question.correctIndex}')));
    await tester.pumpAndSettle();
    expect(find.text('2 / $total'), findsOneWidget);
  });

  testWidgets('the streak chip appears from 2 in a row and resets on a miss',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(find.textContaining('🧩'), findsNothing);
    await answerCorrectly(tester);
    await answerCorrectly(tester);
    expect(find.text('🧩 2'), findsOneWidget);

    await answerWrongOnce(tester);
    await answerCorrectly(tester); // retry, no first-try credit
    expect(find.textContaining('🧩'), findsNothing);
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
                    builder: (_) => const PatternPowerScreen(
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
    await tester.pumpAndSettle();

    // Straight into pattern 1 — no intro.
    expect(find.text("Let's Go!"), findsNothing);
    expect(find.text('1 / 3'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await answerCorrectly(tester);
    }

    expect(popped, isNotNull);
    expect(popped!.completed, isTrue);
    expect(popped!.correctAnswers, 3);
    expect(popped!.totalQuestions, 3);
    expect(popped!.starsAwarded, 0);
    expect(ProgressRepository(storage).stars, 0);
    expect(CoinRepository(storage).coins, 0);
  });

  testWidgets("Fox's help crosses out one wrong option, once per question",
      (tester) async {
    await tester.pumpWidget(await buildHarness(foxEquipped: true));
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fox_hint_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('fox_hint_button')));
    await tester.pumpAndSettle();

    final correctIndex = stateOf(tester).currentQuestion.correctIndex;
    expect(stateOf(tester).eliminatedOptions.length, 1);
    expect(stateOf(tester).eliminatedOptions.contains(correctIndex), isFalse);
    expect(find.byKey(const ValueKey('fox_hint_button')), findsNothing);

    await answerCorrectly(tester);
    expect(find.text('2 / $total'), findsOneWidget);
    expect(find.byKey(const ValueKey('fox_hint_button')), findsOneWidget);
  });

  testWidgets('without Fox equipped, no help button is offered',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fox_hint_button')), findsNothing);
  });
}
