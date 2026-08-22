import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/navigation/app_router.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/welcome/welcome_screen.dart';
import 'package:super_kid_adventure/game/models/hero_profile.dart';
import 'package:super_kid_adventure/game/repositories/hero_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  Widget buildHarness(FakeLocalStorageService storage) {
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.generateRoute,
        home: const WelcomeScreen(),
      ),
    );
  }

  testWidgets('a first-time player sees PLAY and goes to hero preset selection',
      (tester) async {
    await tester.pumpWidget(buildHarness(FakeLocalStorageService()));

    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Continue Adventure'), findsNothing);

    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Your Hero'), findsOneWidget);
  });

  testWidgets(
      'a returning player sees Continue Adventure and goes straight to Home',
      (tester) async {
    final storage = FakeLocalStorageService();
    await HeroRepository(storage).save(HeroProfile.initial());

    await tester.pumpWidget(buildHarness(storage));

    expect(find.text('Continue Adventure'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);

    await tester.tap(find.text('Continue Adventure'));
    await tester.pumpAndSettle();

    expect(find.text('Ready for adventure?'), findsOneWidget);
    // Hero creation is skipped entirely for a returning player.
    expect(find.text('Choose Your Hero'), findsNothing);
  });
}
