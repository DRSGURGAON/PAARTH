import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/navigation/app_router.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/parent_zone/parent_zone_screen.dart';
import 'package:super_kid_adventure/game/models/hero_profile.dart';
import 'package:super_kid_adventure/game/models/quest.dart';
import 'package:super_kid_adventure/game/quests/jungle_quests.dart';
import 'package:super_kid_adventure/game/repositories/coin_repository.dart';
import 'package:super_kid_adventure/game/repositories/hero_repository.dart';
import 'package:super_kid_adventure/game/repositories/play_time_repository.dart';
import 'package:super_kid_adventure/game/repositories/quest_repository.dart';
import 'package:super_kid_adventure/game/systems/difficulty_tracker.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  Widget buildHarness(FakeLocalStorageService storage) {
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        // Reset All Progress navigates by name — wire the real route
        // table so the push resolves instead of throwing.
        onGenerateRoute: AppRouter.generateRoute,
        home: const ParentZoneScreen(),
      ),
    );
  }

  testWidgets('with no progress, shows zeroed stats and recommends Math',
      (tester) async {
    final storage = FakeLocalStorageService();

    await tester.pumpWidget(buildHarness(storage));

    expect(find.text('Less than a minute played'), findsOneWidget);
    expect(find.text('0 of ${JungleQuests.all.length}'), findsOneWidget);
    expect(find.text('Lv 1'), findsNWidgets(4));
    expect(
      find.textContaining('Math is the newest skill'),
      findsOneWidget,
    );
    expect(find.textContaining('Math Dash together'), findsOneWidget);
  });

  testWidgets('reflects real play time, quest, and level data',
      (tester) async {
    final storage = FakeLocalStorageService();
    await PlayTimeRepository(storage).addSeconds(3900); // 1h 5m
    await QuestRepository(storage).markCompleted(JungleQuests.all.first.id);

    final tracker = DifficultyTracker(storage);
    for (var i = 0; i < 3; i++) {
      await tracker.recordResult(ChallengeCategory.math, correct: true);
      await tracker.recordResult(ChallengeCategory.logic, correct: true);
    }

    await tester.pumpWidget(buildHarness(storage));

    expect(find.text('1h 5m played'), findsOneWidget);
    expect(find.text('1 of ${JungleQuests.all.length}'), findsOneWidget);
    expect(find.text('Lv 2'), findsNWidgets(2)); // math, logic
    expect(find.text('Lv 1'), findsNWidgets(2)); // memory, english

    // memory and english are tied for weakest; Memory comes first in
    // ChallengeCategory's declared order, so it's the recommendation.
    expect(
      find.textContaining('Memory is the newest skill'),
      findsOneWidget,
    );
    expect(find.textContaining('Memory Master together'), findsOneWidget);
  });

  testWidgets('cancelling the reset dialog leaves all progress untouched',
      (tester) async {
    final storage = FakeLocalStorageService();
    await CoinRepository(storage).addCoins(50);
    await HeroRepository(storage).save(HeroProfile.initial());

    await tester.pumpWidget(buildHarness(storage));

    await tester.tap(find.byKey(const ValueKey('reset_progress_button')));
    await tester.pumpAndSettle();
    expect(find.text('Reset All Progress?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Reset All Progress?'), findsNothing);
    expect(CoinRepository(storage).coins, 50);
    expect(HeroRepository(storage).hasSavedProfile, isTrue);
    // Still on the dashboard, not bounced back to Welcome.
    expect(find.text('Parent Zone'), findsOneWidget);
  });

  testWidgets('confirming the reset clears storage and returns to Welcome',
      (tester) async {
    final storage = FakeLocalStorageService();
    await CoinRepository(storage).addCoins(50);
    await HeroRepository(storage).save(HeroProfile.initial());
    await PlayTimeRepository(storage).addSeconds(500);

    await tester.pumpWidget(buildHarness(storage));

    await tester.tap(find.byKey(const ValueKey('reset_progress_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm_reset_button')));
    await tester.pumpAndSettle();

    expect(CoinRepository(storage).coins, 0);
    expect(HeroRepository(storage).hasSavedProfile, isFalse);
    expect(PlayTimeRepository(storage).totalSeconds, 0);

    // Landed back on Welcome, as a first-time player would see it —
    // and the whole stack was cleared, so there's no way back to the
    // now-wiped dashboard.
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Parent Zone'), findsNothing);
  });
}
