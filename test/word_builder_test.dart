import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/mini_games/word_builder_screen.dart';
import 'package:super_kid_adventure/game/data/companion_catalog.dart';
import 'package:super_kid_adventure/game/repositories/companion_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;

  Future<Widget> buildHarness({bool puppyEquipped = false}) async {
    storage = FakeLocalStorageService();
    if (puppyEquipped) {
      await CompanionRepository(storage).selectCompanion(CompanionIds.puppy);
    }
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const WordBuilderScreen(),
      ),
    );
  }

  WordBuilderScreenState stateOf(WidgetTester tester) =>
      tester.state<WordBuilderScreenState>(find.byType(WordBuilderScreen));

  /// Taps pool letter tiles in the order needed to spell the current
  /// puzzle's word correctly, one at a time (re-reading live state
  /// between taps, since the pool shrinks after each one).
  Future<void> spellCurrentWord(WidgetTester tester) async {
    final word = stateOf(tester).currentPuzzle.word;
    for (final letter in word.split('')) {
      final tile = stateOf(tester).pool.firstWhere((t) => t.letter == letter);
      await tester.tap(find.byKey(ValueKey('pool_${tile.id}')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('a perfect game scores 6/6 and earns a star', (tester) async {
    await tester.pumpWidget(await buildHarness());

    expect(find.textContaining('earn a ⭐'), findsOneWidget);
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    for (var i = 0; i < WordBuilderScreen.roundLength; i++) {
      expect(
        find.text('Word ${i + 1} of ${WordBuilderScreen.roundLength}'),
        findsOneWidget,
      );
      await spellCurrentWord(tester);
    }

    expect(
      find.text('You got ${WordBuilderScreen.roundLength} '
          'of ${WordBuilderScreen.roundLength}!'),
      findsOneWidget,
    );
    expect(find.textContaining('+1 ⭐'), findsOneWidget);
    expect(ProgressRepository(storage).stars, 1);
  });

  testWidgets('tapping a placed letter returns it to the pool',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    final word = stateOf(tester).currentPuzzle.word;
    final firstTile =
        stateOf(tester).pool.firstWhere((t) => t.letter == word[0]);
    await tester.tap(find.byKey(ValueKey('pool_${firstTile.id}')));
    await tester.pump();

    // Placed into slot 0; tapping that slot should return it to the pool.
    await tester.tap(find.byKey(const ValueKey('slot_0')));
    await tester.pump();

    expect(
      stateOf(tester).pool.any((t) => t.id == firstTile.id),
      isTrue,
    );
  });

  testWidgets('an incorrect order gives the letters back for a retry',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    final word = stateOf(tester).currentPuzzle.word;
    if (word.length < 2 || word.toSet().length < 2) {
      // Extremely unlikely with this seed, but skip defensively if the
      // chosen word can't be meaningfully misordered.
      return;
    }

    // Deliberately place letters in reverse order (wrong, unless the
    // word happens to be a palindrome — not the case for any bank word).
    for (final letter in word.split('').reversed) {
      final tile = stateOf(tester).pool.firstWhere((t) => t.letter == letter);
      await tester.tap(find.byKey(ValueKey('pool_${tile.id}')));
      await tester.pump();
    }

    expect(find.textContaining('!'), findsWidgets);
    expect(stateOf(tester).pool.length, word.length);

    // Retry correctly now.
    await spellCurrentWord(tester);
    expect(find.text('Word 2 of ${WordBuilderScreen.roundLength}'),
        findsOneWidget);
  });

  testWidgets("Puppy places the word's first letter automatically",
      (tester) async {
    await tester.pumpWidget(await buildHarness(puppyEquipped: true));
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    final word = stateOf(tester).currentPuzzle.word;
    expect(stateOf(tester).puppyPlacedLetter, word[0]);
    expect(find.byKey(const ValueKey('puppy_hint_label')), findsOneWidget);
    // Exactly one tile (the placed one) is missing from the pool.
    expect(stateOf(tester).pool.length, word.length - 1);

    // Finish spelling the rest — the round should still complete normally.
    for (final letter in word.substring(1).split('')) {
      final tile = stateOf(tester).pool.firstWhere((t) => t.letter == letter);
      await tester.tap(find.byKey(ValueKey('pool_${tile.id}')));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.text('Word 2 of ${WordBuilderScreen.roundLength}'),
        findsOneWidget);
    // Puppy places the new round's first letter again too.
    expect(
      stateOf(tester).puppyPlacedLetter,
      stateOf(tester).currentPuzzle.word[0],
    );
  });

  testWidgets('without Puppy equipped, no letter is pre-placed',
      (tester) async {
    await tester.pumpWidget(await buildHarness());
    await tester.tap(find.text("Let's Go!"));
    await tester.pump();

    expect(stateOf(tester).puppyPlacedLetter, isNull);
    expect(find.byKey(const ValueKey('puppy_hint_label')), findsNothing);
    expect(
      stateOf(tester).pool.length,
      stateOf(tester).currentPuzzle.word.length,
    );
  });
}
