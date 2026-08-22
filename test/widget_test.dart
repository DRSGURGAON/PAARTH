import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/app.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/game/quests/jungle_quests.dart';
import 'package:super_kid_adventure/game/systems/quest_engine.dart';
import 'package:super_kid_adventure/shared/widgets/shake_widget.dart';

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

  /// PLAY → Start Adventure → Adventure Map (shared start of every flow).
  Future<void> reachAdventureMap(WidgetTester tester) async {
    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Adventure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adventure Map'));
    await tester.pumpAndSettle();
  }

  testWidgets('splash screen shows the game name on launch', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('Super Kid Adventure'), findsOneWidget);
  });

  testWidgets(
      'full V1 flow: welcome -> hero -> home -> map -> quest completed',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await skipSplash(tester);

    // Welcome screen.
    expect(find.text('PLAY'), findsOneWidget);
    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();

    // Hero Selection screen.
    expect(find.text('Build Your Hero'), findsOneWidget);
    expect(find.text('Hair'), findsOneWidget);
    expect(find.text('Outfit'), findsOneWidget);
    expect(find.text('Shoes'), findsOneWidget);
    expect(find.text('Backpack'), findsOneWidget);
    await tester.tap(find.text('Start Adventure'));
    await tester.pumpAndSettle();

    // Home screen — no stars or coins yet (both currency badges show 0).
    expect(find.text('Ready for adventure?'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
    await tester.tap(find.text('Adventure Map'));
    await tester.pumpAndSettle();

    // Adventure Map: entry location unlocked, others locked.
    expect(find.text('Jungle Adventure'), findsOneWidget);
    expect(find.text('Tree House'), findsOneWidget);
    expect(find.text('3 ⭐ to unlock'), findsOneWidget);

    // Enter Tree House: its quest list appears.
    await tester.tap(find.text('Tree House'));
    await tester.pumpAndSettle();
    expect(find.text('Repair the Jungle Bridge'), findsOneWidget);
    expect(find.text('The Treehouse Ladder'), findsOneWidget);

    // Open the bridge quest and read its story intro.
    final quest = JungleQuests.all
        .firstWhere((q) => q.id == 'jungle_bridge_repair');
    await tester.tap(find.text('Repair the Jungle Bridge'));
    await tester.pumpAndSettle();
    expect(find.textContaining('bridge is broken'), findsOneWidget);

    // Play it through, answering every challenge correctly.
    await tester.tap(find.text('Start Quest'));
    await tester.pumpAndSettle();
    for (var i = 0; i < quest.challenges.length; i++) {
      final challenge = quest.challenges[i];
      await tester
          .tap(find.byKey(ValueKey('option_${challenge.correctIndex}')));
      await tester.pumpAndSettle();
      if (i < quest.challenges.length - 1) {
        // Story-item reward dialog between challenges.
        expect(find.textContaining(challenge.rewardLabel!), findsOneWidget);
        await tester.tap(find.text('Next!'));
        await tester.pumpAndSettle();
      }
    }

    // Celebration screen with the one-time star + coin reward.
    expect(find.text('Quest Complete!'), findsOneWidget);
    final expectedCoins = quest.starReward * QuestEngine.coinsPerStar;
    expect(
      find.text('+${quest.starReward} ⭐  +$expectedCoins 🪙'),
      findsOneWidget,
    );

    // Back to the quest list — the quest is now marked completed.
    await tester.tap(find.text('Back to Map'));
    await tester.pumpAndSettle();
    expect(find.text('Completed! Play again for practice'), findsOneWidget);
  });

  testWidgets('a wrong answer shows encouragement and allows retrying',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await skipSplash(tester);
    await reachAdventureMap(tester);

    await tester.tap(find.text('Tree House'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Repair the Jungle Bridge'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Quest'));
    await tester.pumpAndSettle();

    final challenge = JungleQuests.all
        .firstWhere((q) => q.id == 'jungle_bridge_repair')
        .challenges
        .first;
    final wrongIndex =
        (challenge.correctIndex + 1) % challenge.options.length;

    await tester.tap(find.byKey(ValueKey('option_$wrongIndex')));
    await tester.pump(const Duration(milliseconds: 80));

    // The wrong answer actually triggers the options' shake animation,
    // not just the encouragement text.
    final shakeState = tester
        .state<ShakeWidgetState>(find.byType(ShakeWidget));
    expect(shakeState.offset.value, isNot(0));
    await tester.pumpAndSettle();
    expect(shakeState.offset.value, 0);

    // Gentle encouragement, still on the same challenge.
    expect(find.textContaining('Almost!'), findsOneWidget);
    expect(find.text(challenge.prompt), findsOneWidget);

    // The correct answer still works after a miss.
    await tester
        .tap(find.byKey(ValueKey('option_${challenge.correctIndex}')));
    await tester.pumpAndSettle();
    expect(find.textContaining(challenge.rewardLabel!), findsOneWidget);
  });

  testWidgets('tapping a locked location shows a hint instead of opening it',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await skipSplash(tester);
    await reachAdventureMap(tester);

    await tester.tap(find.text('Monkey Camp'));
    await tester.pump();

    expect(find.textContaining('Earn 3 more ⭐'), findsOneWidget);
  });
}
