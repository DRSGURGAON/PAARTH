import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/app.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/features/mini_games/math_dash_screen.dart';
import 'package:super_kid_adventure/features/mini_games/memory_master_screen.dart';
import 'package:super_kid_adventure/features/mini_games/pattern_power_screen.dart';
import 'package:super_kid_adventure/game/models/quest.dart';
import 'package:super_kid_adventure/game/quests/jungle_quests.dart';
import 'package:super_kid_adventure/game/systems/quest_reward_service.dart';
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

  /// PLAY → pick a preset hero → Continue → Adventure Map → the Jungle
  /// world (shared start of every flow). The Adventure Map button opens
  /// the world-select screen first; the jungle card leads to its map.
  Future<void> reachAdventureMap(WidgetTester tester) async {
    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adventure Map'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('world_jungle_adventure')));
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

    // Hero Preset Selection screen: browse, select, continue. No text
    // entry anywhere in this flow — no name is ever asked for.
    expect(find.text('Choose Your Hero'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    expect(find.text('Selected!'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Home screen — no stars, coins, or badges yet (all three show 0).
    expect(find.text('Ready for adventure?'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(3));
    await tester.tap(find.text('Adventure Map'));
    await tester.pumpAndSettle();

    // World select: the jungle is open from the start, the other four
    // worlds honestly locked behind their star thresholds.
    expect(find.text('Adventure Worlds'), findsOneWidget);
    expect(find.text('Jungle Adventure'), findsOneWidget);
    expect(find.text('20 more ⭐ to unlock'), findsOneWidget); // Space
    await tester.tap(find.byKey(const ValueKey('world_jungle_adventure')));
    await tester.pumpAndSettle();

    // Adventure Map: both starter locations unlocked, later ones locked.
    expect(find.text('Jungle Adventure'), findsOneWidget);
    expect(find.text('Tree House'), findsOneWidget);
    expect(find.text('Monkey Camp'), findsOneWidget);
    expect(find.text('6 ⭐ to unlock'), findsOneWidget);

    // Enter Tree House: its quest list appears.
    await tester.tap(find.text('Tree House'));
    await tester.pumpAndSettle();
    expect(find.text('Repair the Jungle Bridge'), findsOneWidget);
    expect(find.text('The Treehouse Ladder'), findsOneWidget);

    // Open the bridge quest: the NPC's story dialogue plays one short
    // line at a time.
    final quest = JungleQuests.all
        .firstWhere((q) => q.id == 'jungle_bridge_repair');
    await tester.tap(find.text('Repair the Jungle Bridge'));
    await tester.pumpAndSettle();
    expect(find.text('Momo the Monkey'), findsOneWidget);
    expect(find.text('Uh-oh!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('dialogue_next')));
    await tester.pumpAndSettle();
    expect(find.text('The jungle bridge is broken!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('dialogue_skip')));
    await tester.pumpAndSettle();

    // Play it through, answering every challenge correctly. The first
    // two challenges embed real Math Dash / Memory Master sessions.
    await tester.tap(find.text('Start Adventure'));
    await tester.pumpAndSettle();
    for (var i = 0; i < quest.challenges.length; i++) {
      final challenge = quest.challenges[i];
      if (challenge is MathDashChallenge) {
        await tester.tap(find.byKey(const ValueKey('play_math_dash')));
        await tester.pumpAndSettle();
        for (var q = 0; q < challenge.questionCount; q++) {
          // Questions are generated — read the live state for the
          // correct option, same as math_dash_test does.
          final dashState = tester
              .state<MathDashScreenState>(find.byType(MathDashScreen));
          final correctIndex = dashState.currentQuestion.correctIndex;
          await tester.tap(find.byKey(ValueKey('option_$correctIndex')));
          await tester.pumpAndSettle();
        }
        // The finished session popped back into the quest.
      } else if (challenge is MemoryMasterChallenge) {
        await tester.tap(find.byKey(const ValueKey('play_memory_master')));
        await tester.pump();
        for (var q = 0; q < challenge.questionCount; q++) {
          final memState = tester.state<MemoryMasterScreenState>(
              find.byType(MemoryMasterScreen));
          await tester.pump(memState.currentStudyDuration +
              const Duration(milliseconds: 50));
          await tester.pumpAndSettle();
          final correctIndex = memState.currentRound.question.correctIndex;
          await tester.tap(find.byKey(ValueKey('option_$correctIndex')));
          await tester.pumpAndSettle();
        }
      } else if (challenge is PatternPowerChallenge) {
        await tester.tap(find.byKey(const ValueKey('play_pattern_power')));
        await tester.pumpAndSettle();
        for (var q = 0; q < challenge.questionCount; q++) {
          final patternState = tester.state<PatternPowerScreenState>(
              find.byType(PatternPowerScreen));
          final correctIndex = patternState.currentQuestion.correctIndex;
          await tester.tap(find.byKey(ValueKey('option_$correctIndex')));
          await tester.pumpAndSettle();
        }
      } else {
        await tester
            .tap(find.byKey(ValueKey('option_${challenge.correctIndex}')));
        await tester.pumpAndSettle();
      }
      // Story-item reward dialog after every solved challenge.
      expect(find.textContaining(challenge.rewardLabel!), findsOneWidget);
      await tester.tap(find.text('Next!'));
      await tester.pumpAndSettle();
    }

    // The bridge-repair story resolution: each tap reveals the next
    // beat, ending on Hooray!
    for (var i = 1; i < quest.resolutionSteps.length; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.textContaining('bridge is fixed'), findsOneWidget);
    await tester.tap(find.text('Hooray!'));
    await tester.pumpAndSettle();

    // Celebration screen with the one-time perfect-run reward (no
    // misses anywhere → bonus star + the perfect coin payout).
    expect(find.text('Quest Complete!'), findsOneWidget);
    final expectedReward = QuestRewardService.calculate(
        baseStarReward: quest.starReward, wrongAttempts: 0);
    expect(
      find.text('+${expectedReward.stars} ⭐  +${expectedReward.coins} 🪙'),
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

    // The bridge quest's first challenges are embedded mini-games with
    // their own gentle wrong-answer handling (covered in their own
    // tests) — exercise the quest-level retry flow on the Treehouse
    // Ladder quest, whose challenges are all fixed-answer.
    await tester.tap(find.text('Tree House'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('The Treehouse Ladder'));
    await tester.pumpAndSettle();
    // Its intro falls back to a single storyIntro line — one tap.
    await tester.tap(find.byKey(const ValueKey('dialogue_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Adventure'));
    await tester.pumpAndSettle();

    final challenge = JungleQuests.all
        .firstWhere((q) => q.id == 'treehouse_ladder')
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

    await tester.tap(find.text('Waterfall'));
    await tester.pump();

    expect(find.textContaining('Earn 6 more ⭐'), findsOneWidget);
  });
}
