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

  testWidgets('splash screen shows the game name on launch', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('Super Kid Adventure'), findsOneWidget);
  });

  testWidgets('Play button on welcome screen navigates onward',
      (tester) async {
    await tester.pumpWidget(buildApp());

    // Let the splash screen's timed navigation fire.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('PLAY'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();

    expect(find.text('Hero Selection'), findsOneWidget);
  });
}
