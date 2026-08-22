import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/navigation/app_router.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/home/home_screen.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  testWidgets('My Room opens the Player Room screen', (tester) async {
    final storage = FakeLocalStorageService();

    await tester.pumpWidget(
      AppScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light,
          // Home navigates by name — wire the real route table so the
          // push resolves instead of throwing.
          onGenerateRoute: AppRouter.generateRoute,
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.ensureVisible(find.text('My Room'));
    await tester.tap(find.text('My Room'));
    await tester.pumpAndSettle();

    // RoomScreen-specific content, since the Home button text ("My Room")
    // would otherwise collide with the pushed screen's own AppBar title.
    expect(find.text('Visit Shop'), findsOneWidget);
  });

  testWidgets('the parent-zone entry opens the gate, not the dashboard '
      'directly', (tester) async {
    final storage = FakeLocalStorageService();

    await tester.pumpWidget(
      AppScope(
        storage: storage,
        child: MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: AppRouter.generateRoute,
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('parent_zone_entry')));
    await tester.pumpAndSettle();

    expect(find.text('For Grown-Ups'), findsOneWidget);
    expect(find.text('Parent Zone'), findsNothing);
  });
}
