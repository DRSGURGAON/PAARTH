import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/mini_games/quick_challenge_screen.dart';
import 'package:super_kid_adventure/game/data/companion_catalog.dart';
import 'package:super_kid_adventure/game/repositories/coin_repository.dart';
import 'package:super_kid_adventure/game/repositories/companion_repository.dart';
import 'package:super_kid_adventure/game/repositories/mini_game_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';
import 'package:super_kid_adventure/game/systems/quest_reward_service.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;
  const total = QuickChallengeScreen.defaultSessionLength;

  Future<Widget> buildHarness({bool cheetahEquipped = false}) async {
    storage = FakeLocalStorageService();
    if (cheetahEquipped) {
      await CompanionRepository(storage)
          .selectCompanion(CompanionIds.cheetah);
    }
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: QuickChallengeScreen(random: Random(42)),
      ),
    );
  }

  QuickChallengeScreenState stateOf(WidgetTester tester) =>
      tester.state<QuickChallengeScreenState>(
          find.byType(QuickChallengeScreen));

  /// Taps every target tile of the current round, completing it.
  Future<void> completeRound(WidgetTester tester) async {
    final targets = stateOf(tester).currentRound.targetIndices.toList();
    for (final index in targets) {
      await tester.tap(find.byKey(ValueKey('tile_$index')));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('a perfect session earns the star plus the perfect-streak '
      'coin bonus and records the Quick Challenge star', (tester) async {
    await tester.pumpWidget(await buildHarness());

    expect(find.text('Fast fingers, quick eyes!'), findsOneWidget);
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    for (var i = 0; i < total; i++) {
      expect(find.text('${i + 1} / $total'), findsOneWidget);
      expect(find.byKey(const ValueKey('round_timer')), findsOneWidget);
      await completeRound(tester);
    }

    expect(find.text('You aced $total of $total rounds!'), findsOneWidget);
    final expected = QuestRewardService.calculateMiniGameSession(
        correctAnswers: total, totalQuestions: total, bestStreak: total);
    expect(find.textContaining('+${expected.stars} ⭐'), findsOneWidget);
    expect(ProgressRepository(storage).stars, expected.stars);
    expect(CoinRepository(storage).coins, expected.coins);
    expect(
      MiniGameRepository(storage).starEarnedGameIds(),
      contains(MiniGameIds.quickChallenge),
    );
  });

  testWidgets('tapping a decoy shows encouragement, keeps the round '
      'going, and only costs the first-try credit', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    final round = stateOf(tester).currentRound;
    final decoyIndex = List.generate(round.tiles.length, (i) => i)
        .firstWhere((i) => !round.targetIndices.contains(i));
    await tester.tap(find.byKey(ValueKey('tile_$decoyIndex')));
    await tester.pumpAndSettle();

    // Gentle feedback, same round still on screen.
    expect(find.text('1 / $total'), findsOneWidget);
    expect(find.text(round.instruction), findsOneWidget);

    // The round still completes and the session moves on.
    await completeRound(tester);
    expect(find.text('2 / $total'), findsOneWidget);

    // Dispose mid-session so the round timer is cancelled.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('running out of time resets the round gently instead of '
      'ending anything', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    final instruction = stateOf(tester).currentRound.instruction;

    for (var s = 0; s < QuickChallengeScreen.roundSeconds; s++) {
      await tester.pump(const Duration(seconds: 1));
    }

    // Same round, fresh timer, friendly message — nothing ended.
    expect(find.text(instruction), findsOneWidget);
    expect(find.textContaining('no rush'), findsOneWidget);
    expect(
      stateOf(tester).secondsLeft,
      QuickChallengeScreen.roundSeconds,
    );
    expect(find.text('1 / $total'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an imperfect session below the star threshold still pays '
      'nothing dishonestly — no star, no star record', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    for (var i = 0; i < total; i++) {
      // Spoil every round with a decoy tap before completing it.
      final round = stateOf(tester).currentRound;
      final decoyIndex = List.generate(round.tiles.length, (i) => i)
          .firstWhere((i) => !round.targetIndices.contains(i));
      await tester.tap(find.byKey(ValueKey('tile_$decoyIndex')));
      await tester.pumpAndSettle();
      await completeRound(tester);
    }

    expect(find.text('You aced 0 of $total rounds!'), findsOneWidget);
    expect(ProgressRepository(storage).stars, 0);
    expect(MiniGameRepository(storage).starEarnedGameIds(), isEmpty);
  });

  testWidgets('Cheetah adds bonus seconds to every round timer',
      (tester) async {
    await tester.pumpWidget(await buildHarness(cheetahEquipped: true));
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(
      stateOf(tester).secondsLeft,
      QuickChallengeScreen.roundSeconds +
          QuickChallengeScreen.cheetahBonusSeconds,
    );

    await tester.pumpWidget(const SizedBox());
  });
}
