import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/navigation/app_router.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/room/room_screen.dart';
import 'package:super_kid_adventure/game/models/shop_item.dart';
import 'package:super_kid_adventure/game/repositories/room_repository.dart';
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
        // Visit Shop navigates by name — wire the real route table so
        // the push resolves instead of throwing.
        onGenerateRoute: AppRouter.generateRoute,
        home: const RoomScreen(),
      ),
    );
  }

  testWidgets('every slot starts empty with a "tap to add" placeholder',
      (tester) async {
    await tester.pumpWidget(await buildHarness());

    expect(find.textContaining('Wall Art — tap to add'), findsOneWidget);
    expect(find.textContaining('Rug — tap to add'), findsOneWidget);
    expect(find.textContaining('Plant — tap to add'), findsOneWidget);
    expect(find.textContaining('Lamp — tap to add'), findsOneWidget);
  });

  testWidgets('an owned item can be equipped from the slot picker',
      (tester) async {
    await tester.pumpWidget(
      await buildHarness(ownedItemIds: {'wallart_stars'}),
    );

    await tester.ensureVisible(find.byKey(const ValueKey('room_slot_wallArt')));
    await tester.tap(find.byKey(const ValueKey('room_slot_wallArt')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('slot_option_wallart_stars')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('slot_option_wallart_stars')));
    await tester.pumpAndSettle();

    expect(find.text('Starry Sky'), findsOneWidget);
    expect(RoomRepository(storage).load().wallArtItemId, 'wallart_stars');
  });

  testWidgets('picking None clears an equipped slot', (tester) async {
    storage = FakeLocalStorageService();
    await ShopRepository(storage).markOwned('rug_stripes');
    await RoomRepository(storage).setSlot(ShopCategory.rug, 'rug_stripes');

    await tester.pumpWidget(
      AppScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: AppRouter.generateRoute,
          home: const RoomScreen(),
        ),
      ),
    );

    expect(find.text('Stripes'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('room_slot_rug')));
    await tester.tap(find.byKey(const ValueKey('room_slot_rug')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('slot_option_none')));
    await tester.pumpAndSettle();

    expect(RoomRepository(storage).load().rugItemId, isNull);
    expect(find.textContaining('Rug — tap to add'), findsOneWidget);
  });

  testWidgets('a slot with nothing owned prompts to visit the Shop instead',
      (tester) async {
    await tester.pumpWidget(await buildHarness());

    await tester.ensureVisible(find.byKey(const ValueKey('room_slot_plant')));
    await tester.tap(find.byKey(const ValueKey('room_slot_plant')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Buy something for this spot'), findsOneWidget);
  });

  testWidgets('Visit Shop opens the Shop screen', (tester) async {
    await tester.pumpWidget(await buildHarness());

    await tester.tap(find.text('Visit Shop'));
    await tester.pumpAndSettle();

    expect(find.text('Shop'), findsOneWidget);
  });
}
