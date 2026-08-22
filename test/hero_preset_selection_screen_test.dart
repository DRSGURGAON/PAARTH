import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/navigation/app_router.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/player/hero_preset_selection_screen.dart';
import 'package:super_kid_adventure/game/data/hero_preset_catalog.dart';
import 'package:super_kid_adventure/game/repositories/hero_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;

  Future<Widget> buildHarness() async {
    storage = FakeLocalStorageService();
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.generateRoute,
        home: const HeroPresetSelectionScreen(),
      ),
    );
  }

  testWidgets('Continue without selecting a preset shows a hint and does not save',
      (tester) async {
    await tester.pumpWidget(await buildHarness());

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.textContaining('Tap Select'), findsOneWidget);
    expect(HeroRepository(storage).hasSavedProfile, isFalse);
  });

  testWidgets('Next browses to a different preset, Select confirms it, '
      'Continue saves it and moves on', (tester) async {
    await tester.pumpWidget(await buildHarness());

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(find.text('Selected!'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final saved = HeroRepository(storage).load();
    expect(saved.hairOptionId, HeroPresetCatalog.presets[1].hairOptionId);
    expect(saved.skinToneId, HeroPresetCatalog.presets[1].skinToneId);
    expect(saved.accessoryId, HeroPresetCatalog.presets[1].accessoryId);
  });

  testWidgets('Previous wraps around to the last preset', (tester) async {
    await tester.pumpWidget(await buildHarness());

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    expect(
      find.text('Hero ${HeroPresetCatalog.presets.length} of '
          '${HeroPresetCatalog.presets.length}'),
      findsOneWidget,
    );
  });
}
