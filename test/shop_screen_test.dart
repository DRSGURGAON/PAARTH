import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/shop/shop_screen.dart';
import 'package:super_kid_adventure/game/repositories/coin_repository.dart';
import 'package:super_kid_adventure/game/repositories/shop_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;

  Future<Widget> buildHarness({int coins = 0}) async {
    storage = FakeLocalStorageService();
    if (coins > 0) {
      await CoinRepository(storage).addCoins(coins);
    }
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const ShopScreen(),
      ),
    );
  }

  testWidgets('lists every catalog item with its price', (tester) async {
    await tester.pumpWidget(await buildHarness());

    expect(find.byKey(const ValueKey('shop_item_hair_rose')), findsOneWidget);
    expect(find.byKey(const ValueKey('shop_item_lamp_rocket')), findsOneWidget);
    expect(find.text('10 🪙'), findsWidgets);
  });

  testWidgets('an affordable item can be bought; an unaffordable one cannot',
      (tester) async {
    // Enough for the 10-coin item, not the 20-coin one.
    await tester.pumpWidget(await buildHarness(coins: 15));

    final cheapBuy = tester.widget<FilledButton>(
      find.byKey(const ValueKey('buy_hair_rose')),
    );
    final expensiveBuy = tester.widget<FilledButton>(
      find.byKey(const ValueKey('buy_hair_ocean')),
    );
    expect(cheapBuy.onPressed, isNotNull);
    expect(expensiveBuy.onPressed, isNull);
  });

  testWidgets('buying spends coins and marks the item owned', (tester) async {
    await tester.pumpWidget(await buildHarness(coins: 15));

    await tester.tap(find.byKey(const ValueKey('buy_hair_rose')));
    await tester.pumpAndSettle();

    expect(CoinRepository(storage).coins, 5);
    expect(ShopRepository(storage).ownedItemIds(), {'hair_rose'});
    expect(find.text('Owned'), findsOneWidget);

    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('buy_hair_rose')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('an already-owned item cannot be bought again', (tester) async {
    final seedStorage = FakeLocalStorageService();
    await CoinRepository(seedStorage).addCoins(100);
    await ShopRepository(seedStorage).markOwned('hair_rose');
    storage = seedStorage;

    await tester.pumpWidget(
      AppScope(
        storage: storage,
        child: MaterialApp(theme: AppTheme.light, home: const ShopScreen()),
      ),
    );

    expect(find.text('Owned'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('buy_hair_rose')));
    await tester.pumpAndSettle();

    // Still 100 — the disabled button did nothing.
    expect(CoinRepository(storage).coins, 100);
  });
}
