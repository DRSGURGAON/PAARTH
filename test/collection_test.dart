import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/collection/collection_screen.dart';
import 'package:super_kid_adventure/game/data/badge_catalog.dart';
import 'package:super_kid_adventure/game/repositories/coin_repository.dart';
import 'package:super_kid_adventure/game/repositories/mini_game_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  /// The badge grid (10 cards, 2 columns) is taller than the default
  /// 800x600 test surface, so GridView.builder would only build the
  /// on-screen cards and undercount locks/badges. Enlarge the surface
  /// so every card actually renders, matching what a real tall phone
  /// screen (or a scroll) would eventually show.
  Future<void> pumpTallCollection(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app);
  }

  testWidgets('with no progress, every badge shows as locked (0 earned)',
      (tester) async {
    final storage = FakeLocalStorageService();

    await pumpTallCollection(
      tester,
      AppScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CollectionScreen(),
        ),
      ),
    );

    expect(
      find.text('0 of ${BadgeCatalog.all.length} badges earned'),
      findsOneWidget,
    );
    expect(
      find.byIcon(Icons.lock_rounded),
      findsNWidgets(BadgeCatalog.all.length),
    );
  });

  testWidgets(
      'earning a mini-game star unlocks that badge, others stay locked',
      (tester) async {
    final storage = FakeLocalStorageService();
    await MiniGameRepository(storage).markStarEarned(MiniGameIds.mathDash);

    await pumpTallCollection(
      tester,
      AppScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CollectionScreen(),
        ),
      ),
    );

    expect(find.text('1 of ${BadgeCatalog.all.length} badges earned'),
        findsOneWidget);
    expect(find.text('Math Whiz'), findsOneWidget);
    expect(find.text('Earn a star in Math Dash.'), findsOneWidget);
    // Only 1 badge earned, so exactly (total - 1) locks remain.
    expect(find.byIcon(Icons.lock_rounded),
        findsNWidgets(BadgeCatalog.all.length - 1));
  });

  testWidgets('star and coin totals feed the Star/Coin Collector badges',
      (tester) async {
    final storage = FakeLocalStorageService();
    await ProgressRepository(storage).addStars(20);
    await CoinRepository(storage).addCoins(20);

    await pumpTallCollection(
      tester,
      AppScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CollectionScreen(),
        ),
      ),
    );

    expect(find.text('Star Collector'), findsOneWidget);
    expect(find.text('Coin Collector'), findsOneWidget);
    expect(find.text('2 of ${BadgeCatalog.all.length} badges earned'),
        findsOneWidget);
  });
}
