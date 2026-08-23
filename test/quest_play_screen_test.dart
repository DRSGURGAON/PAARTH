import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/quests/quest_play_screen.dart';
import 'package:super_kid_adventure/game/models/quest.dart';

import 'support/fake_local_storage_service.dart';

/// Covers the authored [MemoryChallenge] path directly: the jungle
/// content now uses embedded Memory Master sessions for its memory
/// moments, but the hand-authored study-then-answer challenge type
/// remains a real, supported authoring option for future quests.
void main() {
  const quest = Quest(
    id: 'test_memory_quest',
    locationId: 'tree_house',
    title: 'Test Memory Quest',
    storyIntro: 'intro',
    storyOutro: 'outro',
    starReward: 2,
    challenges: [
      MemoryChallenge(
        studyPrompt: 'Remember these friends!',
        itemsToRemember: '🐒 🐼',
        prompt: 'Which friends did you see?',
        options: ['🐒 🐼', '🐒 🦁', '🐸 🐼'],
        correctIndex: 0,
        hint: 'One pair is exactly who you met!',
        rewardLabel: 'Test Reward',
      ),
    ],
  );

  Widget buildHarness() {
    return AppScope(
      storage: FakeLocalStorageService(),
      child: MaterialApp(
        theme: AppTheme.light,
        home: const QuestPlayScreen(quest: quest),
      ),
    );
  }

  testWidgets('an authored memory challenge studies, hides, hints on a '
      'miss, and completes on the right answer', (tester) async {
    await tester.pumpWidget(buildHarness());
    await tester.pumpAndSettle();

    // Study phase: items visible until the child says they're ready.
    expect(find.text('Remember these friends!'), findsOneWidget);
    expect(find.text('🐒 🐼'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('memory_ready')));
    await tester.pumpAndSettle();

    // Items hidden, question shown.
    expect(find.text('Which friends did you see?'), findsOneWidget);

    // A miss gets encouragement plus the authored hint, and a retry.
    await tester.tap(find.byKey(const ValueKey('option_1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Almost!'), findsOneWidget);
    expect(find.textContaining('One pair is exactly who you met!'),
        findsOneWidget);

    // The correct answer completes the quest (single-challenge quest).
    await tester.tap(find.byKey(const ValueKey('option_0')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Test Reward'), findsOneWidget);
    await tester.tap(find.text('Next!'));
    await tester.pumpAndSettle();
    expect(find.text('Quest Complete!'), findsOneWidget);
  });
}
