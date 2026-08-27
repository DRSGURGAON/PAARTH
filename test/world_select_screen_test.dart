import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/adventure_map/world_select_screen.dart';
import 'package:super_kid_adventure/game/quests/quest_catalog.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';
import 'package:super_kid_adventure/game/repositories/quest_repository.dart';
import 'package:super_kid_adventure/game/worlds/jungle_world.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  Future<Widget> buildHarness({
    int stars = 0,
    Set<String>? completedQuestIds,
  }) async {
    final storage = FakeLocalStorageService();
    if (stars > 0) await ProgressRepository(storage).addStars(stars);
    for (final id in completedQuestIds ?? const <String>{}) {
      await QuestRepository(storage).markCompleted(id);
    }
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const WorldSelectScreen(),
      ),
    );
  }

  testWidgets('shows all five worlds, with only the jungle open at zero '
      'stars', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.pumpAndSettle();

    expect(find.text('Jungle Adventure'), findsOneWidget);
    expect(find.text('Space Mission'), findsOneWidget);
    expect(find.text('Dino Island'), findsOneWidget);
    expect(find.text('Magic Kingdom'), findsOneWidget);
    expect(find.text('Robot City'), findsOneWidget);
    expect(find.text('20 more ⭐ to unlock'), findsOneWidget);
    expect(find.text('42 more ⭐ to unlock'), findsOneWidget);
    expect(find.text('62 more ⭐ to unlock'), findsOneWidget);
    expect(find.text('82 more ⭐ to unlock'), findsOneWidget);
    // The open jungle shows progress, not a lock.
    final jungleTotal = JungleWorld.locations
        .expand((l) => QuestCatalog.forLocation(l.id))
        .length;
    expect(find.text('0 / $jungleTotal quests done'), findsOneWidget);
  });

  testWidgets('an unlocked world card shows its quest progress',
      (tester) async {
    final treeHouseQuests = QuestCatalog.forLocation('tree_house');
    await tester.pumpWidget(await buildHarness(
      stars: 4,
      completedQuestIds: treeHouseQuests.map((q) => q.id).toSet(),
    ));
    await tester.pumpAndSettle();

    final jungleTotal = JungleWorld.locations
        .expand((l) => QuestCatalog.forLocation(l.id))
        .length;
    expect(
      find.text('${treeHouseQuests.length} / $jungleTotal quests done'),
      findsOneWidget,
    );
  });

  testWidgets('tapping a locked world shakes and hints instead of '
      'navigating', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('world_space_mission')));
    await tester.pump();

    expect(find.textContaining('Earn 20 more ⭐'), findsOneWidget);
    // Still on the world select — no map AppBar pushed.
    expect(find.text('Adventure Worlds'), findsOneWidget);
  });

  testWidgets('tapping the jungle opens its map, and unlocking a later '
      'world makes it tappable too', (tester) async {
    await tester.pumpWidget(await buildHarness(stars: 20));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('world_space_mission')));
    await tester.pumpAndSettle();

    expect(find.text('Space Station'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('world_jungle_adventure')));
    await tester.pumpAndSettle();

    expect(find.text('Tree House'), findsOneWidget);
  });
}
