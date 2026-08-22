import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/adventure_map/adventure_map_screen.dart';
import 'package:super_kid_adventure/game/quests/jungle_quests.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';
import 'package:super_kid_adventure/game/repositories/quest_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  Future<Widget> buildHarness({int stars = 0, Set<String>? completedQuestIds}) async {
    final storage = FakeLocalStorageService();
    if (stars > 0) await ProgressRepository(storage).addStars(stars);
    for (final id in completedQuestIds ?? const <String>{}) {
      await QuestRepository(storage).markCompleted(id);
    }
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const AdventureMapScreen(),
      ),
    );
  }

  testWidgets('Tree House and Monkey Camp are unlocked with zero stars',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.pumpAndSettle();

    expect(find.text('Tree House'), findsOneWidget);
    expect(find.text('Monkey Camp'), findsOneWidget);
    expect(find.text('6 ⭐ to unlock'), findsOneWidget); // Waterfall
    expect(find.text('10 ⭐ to unlock'), findsOneWidget); // Lion Cave
    expect(find.text('14 ⭐ to unlock'), findsOneWidget); // Mountain
    expect(find.text('16 ⭐ to unlock'), findsOneWidget); // Jungle Temple
  });

  testWidgets('tapping a locked location shows a hint and does not navigate',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Waterfall'));
    await tester.pump();

    expect(find.textContaining('Earn 6 more ⭐'), findsOneWidget);
    // Still on the map — no location AppBar title pushed.
    expect(find.text('Jungle Adventure'), findsOneWidget);
  });

  testWidgets(
      'tapping an unlocked location opens it, and back navigation returns to the map',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tree House'));
    await tester.pumpAndSettle();

    expect(find.text('Repair the Jungle Bridge'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Jungle Adventure'), findsOneWidget);
    expect(find.text('Tree House'), findsOneWidget);
  });

  testWidgets('a location with every quest completed shows the completed state',
      (tester) async {
    final treeHouseQuestIds =
        JungleQuests.forLocation('tree_house').map((q) => q.id).toSet();
    await tester.pumpWidget(
      await buildHarness(stars: 4, completedQuestIds: treeHouseQuestIds),
    );
    await tester.pumpAndSettle();

    expect(find.text('✓ 4 ⭐ earned'), findsOneWidget);
  });

  testWidgets('a location with only some quests completed is not marked completed',
      (tester) async {
    final oneQuestId = JungleQuests.forLocation('tree_house').first.id;
    await tester.pumpWidget(
      await buildHarness(stars: 2, completedQuestIds: {oneQuestId}),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('earned'), findsNothing);
  });

  testWidgets(
      'opening Mountain before it has quest content shows a friendly '
      'coming-soon screen instead of an empty or fake quest list',
      (tester) async {
    await tester.pumpWidget(await buildHarness(stars: 14));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mountain'));
    await tester.pumpAndSettle();

    expect(find.textContaining('coming to Mountain soon'), findsOneWidget);
  });

  testWidgets('locked, unlocked, and completed nodes each carry a distinct '
      'semantic label, not just a color difference', (tester) async {
    final handle = tester.ensureSemantics();
    addTearDown(handle.dispose);

    final treeHouseQuestIds =
        JungleQuests.forLocation('tree_house').map((q) => q.id).toSet();
    await tester.pumpWidget(
      await buildHarness(stars: 4, completedQuestIds: treeHouseQuestIds),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp('Tree House, completed with 4 stars')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Monkey Camp, unlocked')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Waterfall, locked')),
      findsOneWidget,
    );
  });
}
