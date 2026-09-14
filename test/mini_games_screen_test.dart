import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/mini_games/mini_games_screen.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  Widget buildHarness() => AppScope(
        storage: FakeLocalStorageService(),
        child: const MaterialApp(
          home: MiniGamesScreen(),
        ),
      );

  testWidgets('the hub lists all six built mini-games', (tester) async {
    await tester.pumpWidget(buildHarness());

    for (final title in const [
      'Math Dash',
      'Memory Master',
      'Pattern Power',
      'Word Builder',
      'Find & Discover',
      'Quick Challenge',
    ]) {
      // The list is taller than the test surface, so scroll each card
      // into view before asserting it is really there.
      final card = find.text(title);
      await tester.scrollUntilVisible(card, 120);
      expect(card, findsOneWidget, reason: '$title is missing from the hub');
    }
  });

  testWidgets('Quick Challenge opens from the hub', (tester) async {
    await tester.pumpWidget(
      AppScope(
        storage: FakeLocalStorageService(),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MiniGamesScreen(),
        ),
      ),
    );

    final card = find.text('Quick Challenge');
    await tester.scrollUntilVisible(card, 120);
    await tester.tap(card);
    await tester.pumpAndSettle();

    // The intro's own copy, not the hub subtitle that shares its words.
    expect(find.textContaining('speedy rounds'), findsOneWidget);
    expect(find.text("Let's Go!"), findsOneWidget);
  });
}
