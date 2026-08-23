import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/mini_games/find_discover_screen.dart';
import 'package:super_kid_adventure/game/data/companion_catalog.dart';
import 'package:super_kid_adventure/game/repositories/companion_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;

  Future<Widget> buildHarness({bool monkeyEquipped = false}) async {
    storage = FakeLocalStorageService();
    if (monkeyEquipped) {
      await CompanionRepository(storage).selectCompanion(CompanionIds.monkey);
    }
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const FindDiscoverScreen(),
      ),
    );
  }

  FindDiscoverScreenState stateOf(WidgetTester tester) => tester
      .state<FindDiscoverScreenState>(find.byType(FindDiscoverScreen));

  /// Taps only the target items in the current scene, in order — a
  /// clean round with no wrong taps.
  Future<void> findAllTargetsCleanly(WidgetTester tester) async {
    final scene = stateOf(tester).currentScene;
    for (var i = 0; i < scene.items.length; i++) {
      if (scene.items[i].isTarget) {
        await tester.tap(find.byKey(ValueKey('find_item_$i')));
        await tester.pump();
      }
    }
    await tester.pumpAndSettle();
  }

  testWidgets('finding every target cleanly across all rounds earns a star',
      (tester) async {
    await tester.pumpWidget(await buildHarness());

    expect(find.textContaining('earn a ⭐'), findsOneWidget);
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    for (var i = 0; i < FindDiscoverScreen.roundLength; i++) {
      expect(
        find.text('Scene ${i + 1} of ${FindDiscoverScreen.roundLength}'),
        findsOneWidget,
      );
      await findAllTargetsCleanly(tester);
    }

    expect(
      find.text('${FindDiscoverScreen.roundLength} of '
          '${FindDiscoverScreen.roundLength} scenes clean!'),
      findsOneWidget,
    );
    expect(find.textContaining('+1 ⭐'), findsOneWidget);
    expect(ProgressRepository(storage).stars, 1);
  });

  testWidgets('a wrong tap does not block finishing the scene, but costs '
      'the clean bonus', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    final scene = stateOf(tester).currentScene;
    final decoyIndex = scene.items.indexWhere((it) => !it.isTarget);
    await tester.tap(find.byKey(ValueKey('find_item_$decoyIndex')));
    await tester.pump();

    await findAllTargetsCleanly(tester);

    // Round still completed (advanced to round 2) despite the mistake.
    expect(find.text('Scene 2 of ${FindDiscoverScreen.roundLength}'),
        findsOneWidget);
  });

  testWidgets('tapping an already-found target again does nothing',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    final scene = stateOf(tester).currentScene;
    final targetIndex = scene.items.indexWhere((it) => it.isTarget);
    await tester.tap(find.byKey(ValueKey('find_item_$targetIndex')));
    await tester.pump();
    await tester.tap(find.byKey(ValueKey('find_item_$targetIndex')));
    await tester.pump();

    // Still on round 1 — a double-tap on one target didn't finish it.
    expect(find.text('Scene 1 of ${FindDiscoverScreen.roundLength}'),
        findsOneWidget);
  });

  testWidgets('Monkey points at one real target in every scene',
      (tester) async {
    await tester.pumpWidget(await buildHarness(monkeyEquipped: true));
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    for (var i = 0; i < FindDiscoverScreen.roundLength; i++) {
      final state = stateOf(tester);
      expect(state.hintedIndex, greaterThanOrEqualTo(0));
      expect(state.currentScene.items[state.hintedIndex].isTarget, isTrue);
      await findAllTargetsCleanly(tester);
    }
  });

  testWidgets('without Monkey equipped, no item is hinted', (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    expect(stateOf(tester).hintedIndex, -1);
  });
}
