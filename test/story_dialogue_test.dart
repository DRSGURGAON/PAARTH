import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/quests/story_dialogue.dart';
import 'package:super_kid_adventure/game/models/quest.dart';

void main() {
  const npc = QuestNpc(name: 'Momo the Monkey', emoji: '🐒');
  const lines = ['Uh-oh!', 'The bridge is broken!', 'Can you help?'];

  Widget buildHarness({required VoidCallback onFinished}) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: StoryDialogue(npc: npc, lines: lines, onFinished: onFinished),
      ),
    );
  }

  testWidgets('shows the NPC and one line at a time, Next advancing through '
      'them and finishing on the last', (tester) async {
    var finished = false;
    await tester.pumpWidget(buildHarness(onFinished: () => finished = true));
    await tester.pumpAndSettle();

    expect(find.text('Momo the Monkey'), findsOneWidget);
    expect(find.text('🐒'), findsOneWidget);
    expect(find.text('Uh-oh!'), findsOneWidget);
    expect(find.text('The bridge is broken!'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('dialogue_next')));
    await tester.pumpAndSettle();
    expect(find.text('The bridge is broken!'), findsOneWidget);
    expect(find.text('Uh-oh!'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('dialogue_next')));
    await tester.pumpAndSettle();
    expect(find.text('Can you help?'), findsOneWidget);
    expect(finished, isFalse);

    // The last line's button reads "Let's go!" and finishes.
    expect(find.text("Let's go!"), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('dialogue_next')));
    expect(finished, isTrue);
  });

  testWidgets('Skip finishes immediately from any line', (tester) async {
    var finished = false;
    await tester.pumpWidget(buildHarness(onFinished: () => finished = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('dialogue_skip')));

    expect(finished, isTrue);
  });

  testWidgets('a single-line dialogue offers no Skip and finishes on one tap',
      (tester) async {
    var finished = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: StoryDialogue(
          lines: const ['Just one line.'],
          onFinished: () => finished = true,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dialogue_skip')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('dialogue_next')));
    expect(finished, isTrue);
  });
}
