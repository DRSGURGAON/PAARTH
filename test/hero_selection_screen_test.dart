import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/navigation/app_router.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/player/hero_selection_screen.dart';
import 'package:super_kid_adventure/game/repositories/hero_repository.dart';
import 'package:super_kid_adventure/game/repositories/shop_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;

  Future<Widget> buildHarness({Set<String> ownedItemIds = const {}}) async {
    storage = FakeLocalStorageService();
    for (final id in ownedItemIds) {
      await ShopRepository(storage).markOwned(id);
    }
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        // Start Adventure navigates by name (RouteNames.home) — wire the
        // real route table so that push resolves instead of throwing.
        onGenerateRoute: AppRouter.generateRoute,
        home: const HeroSelectionScreen(),
      ),
    );
  }

  testWidgets('with nothing owned, only the 4 free swatches show per row',
      (tester) async {
    await tester.pumpWidget(await buildHarness());

    expect(find.byKey(const ValueKey('swatch_sunshine')), findsOneWidget);
    expect(find.byKey(const ValueKey('swatch_hair_rose')), findsNothing);
  });

  testWidgets('a purchased hair color appears as an extra swatch and is '
      'selectable and saved', (tester) async {
    await tester.pumpWidget(
      await buildHarness(ownedItemIds: {'hair_rose'}),
    );

    expect(find.byKey(const ValueKey('swatch_hair_rose')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('swatch_hair_rose')));
    await tester.pump();

    await tester.tap(find.text('Start Adventure'));
    await tester.pumpAndSettle();

    expect(HeroRepository(storage).load().hairOptionId, 'hair_rose');
  });

  testWidgets('a shop item never owned for that category is not offered',
      (tester) async {
    // Owns a hair item, not an outfit item — the outfit row must be
    // unaffected.
    await tester.pumpWidget(
      await buildHarness(ownedItemIds: {'hair_rose'}),
    );

    expect(find.byKey(const ValueKey('swatch_outfit_sunset')), findsNothing);
  });
}
