import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/parent_zone/parent_zone_screen.dart';
import 'package:super_kid_adventure/game/models/quest.dart';
import 'package:super_kid_adventure/game/quests/jungle_quests.dart';
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
}
