import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/app.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  Widget buildApp() {
    return AppScope(
      storage: FakeLocalStorageService(),
      child: const SuperKidAdventureApp(),
    );
  }

  Future<void> skipSplash(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  testWidgets('splash screen shows the game name on launch', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('Super Kid Adventure'), findsOneWidget);
  });

  testWidgets(
      'full V1 flow: welcome -> hero selection -> home -> adventure map',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await skipSplash(tester);

    // Welcome screen.
    expect(find.text('PLAY'), findsOneWidget);
    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();

    // Hero Selection screen: customize, then start.
    expect(find.text('Build Your Hero'), findsOneWidget);
    expect(find.text('Hair'), findsOneWidget);
    expect(find.text('Outfit'), findsOneWidget);
    expect(find.text('Shoes'), findsOneWidget);
    expect(find.text('Backpack'), findsOneWidget);

    await tester.tap(find.text('Start Adventure'));
    await tester.pumpAndSettle();

    // Home screen.
    expect(find.text('Ready for adventure?'), findsOneWidget);
    expect(find.text('Adventure Map'), findsOneWidget);
    // No stars earned yet (no quests exist until Phase 3).
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('Adventure Map'));
    await tester.pumpAndSettle();

    // Adventure Map: entry location unlocked, others locked.
    expect(find.text('Jungle Adventure'), findsOneWidget);
    expect(find.text('Tree House'), findsOneWidget);
    expect(find.text('Monkey Camp'), findsOneWidget);
    expect(find.text('3 ⭐ to unlock'), findsOneWidget);

    // Tapping the unlocked location opens its (placeholder) quest. Note:
    // the Adventure Map stays mounted underneath (Navigator's default
    // maintainState), so "Tree House" now matches twice — assert on the
    // placeholder's unique text instead.
    await tester.tap(find.text('Tree House'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Phase 3'), findsOneWidget);
  });

  testWidgets('tapping a locked location shows a hint instead of opening it',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await skipSplash(tester);

    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Adventure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adventure Map'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Monkey Camp'));
    await tester.pump();

    expect(find.textContaining('Earn 3 more ⭐'), findsOneWidget);
  });
}
