import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/quest.dart';
import 'package:super_kid_adventure/game/quests/jungle_quests.dart';
import 'package:super_kid_adventure/game/worlds/jungle_world.dart';

/// Content sanity checks: quests are data, so typos in a content file
/// (bad correctIndex, unknown location id, unreachable unlock) should
/// fail a test — not surface as a broken experience for a 7-year-old.
void main() {
  group('JungleQuests content', () {
    test('meets the V1 minimum of 10 complete quests', () {
      expect(JungleQuests.all.length, greaterThanOrEqualTo(10));
    });

    test('quest ids are unique', () {
      final ids = JungleQuests.all.map((q) => q.id).toList();

      expect(ids.toSet().length, ids.length);
    });

    test('every quest belongs to a real Jungle location', () {
      final locationIds = JungleWorld.locations.map((l) => l.id).toSet();

      for (final quest in JungleQuests.all) {
        expect(locationIds, contains(quest.locationId),
            reason: 'Quest ${quest.id} points at unknown location '
                '${quest.locationId}');
      }
    });

    test('every location has at least one quest, except Mountain', () {
      // Mountain ships real and honestly-locked in the map (Phase 2
      // redesign), but its quest content hasn't been authored yet —
      // deliberate scope exclusion, not a content gap. See JungleWorld's
      // doc comment and LocationQuestsScreen's "coming soon" state.
      for (final location in JungleWorld.locations) {
        if (location.id == 'mountain') continue;
        expect(JungleQuests.forLocation(location.id), isNotEmpty,
            reason: '${location.name} has no quests');
      }
    });

    test('Mountain intentionally has no quests yet', () {
      expect(JungleQuests.forLocation('mountain'), isEmpty);
    });

    test('every challenge is well-formed', () {
      for (final quest in JungleQuests.all) {
        expect(quest.challenges.length, greaterThanOrEqualTo(3),
            reason: 'Quest ${quest.id} has too few challenges');
        expect(quest.starReward, greaterThan(0));

        for (final challenge in quest.challenges) {
          expect(challenge.prompt, isNotEmpty);
          // Embedded mini-game sessions generate their questions at
          // play time; the fixed options are engine bookkeeping, not
          // child-facing.
          if (challenge is MathDashChallenge) {
            expect(challenge.questionCount, greaterThan(0));
            continue;
          }
          if (challenge is MemoryMasterChallenge) {
            expect(challenge.questionCount, greaterThan(0));
            continue;
          }
          if (challenge is PatternPowerChallenge) {
            expect(challenge.questionCount, greaterThan(0));
            continue;
          }
          expect(challenge.options.length, greaterThanOrEqualTo(2),
              reason: 'A challenge in ${quest.id} has too few options');
          expect(
            challenge.correctIndex,
            inInclusiveRange(0, challenge.options.length - 1),
            reason: 'A challenge in ${quest.id} has an out-of-range '
                'correctIndex',
          );
        }
      }
    });

    test('the first quest tells its full story: NPC, dialogue, all three '
        'embedded mini-games, and a bridge-repair resolution', () {
      final quest =
          JungleQuests.all.firstWhere((q) => q.id == 'jungle_bridge_repair');

      expect(quest.npc, isNotNull);
      expect(quest.introDialogue.length, greaterThanOrEqualTo(3));
      expect(quest.resolutionSteps.length, greaterThanOrEqualTo(3));
      // Spec'd challenge order: Math Dash → Memory Master → Pattern
      // Power.
      expect(quest.challenges[0], isA<MathDashChallenge>());
      expect(quest.challenges[1], isA<MemoryMasterChallenge>());
      expect(quest.challenges[2], isA<PatternPowerChallenge>());
      for (final challenge in quest.challenges) {
        expect(challenge.rewardLabel, isNotNull);
      }
    });

    test('star economy makes every location reachable', () {
      // Stars earnable from all locations unlocked before location N
      // must cover location N's own threshold.
      for (final location in JungleWorld.locations) {
        final earnableBefore = JungleWorld.locations
            .where((l) => l.requiredStars < location.requiredStars)
            .expand((l) => JungleQuests.forLocation(l.id))
            .fold<int>(0, (sum, quest) => sum + quest.starReward);

        expect(earnableBefore, greaterThanOrEqualTo(location.requiredStars),
            reason: '${location.name} needs ${location.requiredStars} '
                'stars but only $earnableBefore are earnable before it');
      }
    });
  });
}
