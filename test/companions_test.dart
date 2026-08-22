import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/companions/companion_select_screen.dart';
import 'package:super_kid_adventure/game/data/companion_catalog.dart';
import 'package:super_kid_adventure/game/repositories/companion_repository.dart';
import 'package:super_kid_adventure/game/repositories/mini_game_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  /// The companion grid (5 cards, 2 columns) is taller than the default
  /// 800x600 test surface — same reasoning as Collection's own helper.
  Future<void> pumpTallCompanions(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app);
  }

  testWidgets('with no mini-game stars, every companion is locked',
      (tester) async {
    final storage = FakeLocalStorageService();

    await pumpTallCompanions(
      tester,
      AppScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CompanionSelectScreen(),
        ),
      ),
    );

    expect(
      find.byIcon(Icons.lock_rounded),
      findsNWidgets(CompanionCatalog.all.length),
    );
    expect(find.text('Tap a companion to bring them along!'), findsOneWidget);
  });

  testWidgets('earning a mini-game star unlocks its companion for tapping',
      (tester) async {
    final storage = FakeLocalStorageService();
    await MiniGameRepository(storage).markStarEarned(MiniGameIds.mathDash);

    await pumpTallCompanions(
      tester,
      AppScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CompanionSelectScreen(),
        ),
      ),
    );

    expect(find.text('Robot'), findsOneWidget);
    expect(
      find.byIcon(Icons.lock_rounded),
      findsNWidgets(CompanionCatalog.all.length - 1),
    );

    await tester.tap(find.byKey(const ValueKey('companion_robot')));
    await tester.pumpAndSettle();

    expect(CompanionRepository(storage).selectedCompanionId, 'robot');
    expect(find.text('Your active helper is highlighted.'), findsOneWidget);
  });

  testWidgets('tapping a locked companion does nothing', (tester) async {
    final storage = FakeLocalStorageService();

    await pumpTallCompanions(
      tester,
      AppScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CompanionSelectScreen(),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('companion_robot')));
    await tester.pumpAndSettle();

    expect(CompanionRepository(storage).selectedCompanionId, isNull);
  });
}
