import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/quest.dart';
import 'package:super_kid_adventure/game/quests/quest_catalog.dart';
import 'package:super_kid_adventure/game/worlds/jungle_world.dart';
import 'package:super_kid_adventure/game/worlds/worlds.dart';

/// Cross-world content sanity: with five worlds' quests in one catalog,
/// a typo in any content file (duplicate id, unknown location,
/// unreachable unlock threshold, malformed challenge) should fail here
/// — not surface as a broken experience for a 7-year-old.
void main() {
  group('Worlds registry', () {
    test('has the five designed worlds in play order', () {
      expect(
        Worlds.all.map((w) => w.id).toList(),
        [
          'jungle_adventure',
          'space_mission',
          'dino_island',
          'magic_kingdom',
          'robot_city',
        ],
      );
    });

    test('world unlock thresholds strictly increase', () {
      for (var i = 1; i < Worlds.all.length; i++) {
        expect(
          Worlds.all[i].requiredStars,
          greaterThan(Worlds.all[i - 1].requiredStars),
          reason: '${Worlds.all[i].name} must cost more than '
              '${Worlds.all[i - 1].name}',
        );
      }
    });

    test('location ids are unique across all worlds', () {
      final ids =
          Worlds.all.expand((w) => w.locations).map((l) => l.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every location unlocks at or after its own world', () {
      for (final world in Worlds.all) {
        for (final location in world.locations) {
          expect(
            location.requiredStars,
            greaterThanOrEqualTo(world.requiredStars),
            reason: '${location.name} would unlock before ${world.name}',
          );
        }
      }
    });

    test('byId finds each world', () {
      for (final world in Worlds.all) {
        expect(Worlds.byId(world.id), same(world));
      }
    });
  });

  group('QuestCatalog content', () {
    test('quest ids are unique across all worlds', () {
      final ids = QuestCatalog.all.map((q) => q.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every quest belongs to a real location, and every location '
        'has at least two quests', () {
      final locationIds =
          Worlds.all.expand((w) => w.locations).map((l) => l.id).toSet();
      for (final quest in QuestCatalog.all) {
        expect(locationIds, contains(quest.locationId),
            reason: 'Quest ${quest.id} points at unknown location '
                '${quest.locationId}');
      }
      for (final id in locationIds) {
        expect(QuestCatalog.forLocation(id).length, greaterThanOrEqualTo(2),
            reason: 'Location $id has too few quests');
      }
    });

    test('every challenge is well-formed', () {
      for (final quest in QuestCatalog.all) {
        expect(quest.challenges.length, greaterThanOrEqualTo(3),
            reason: 'Quest ${quest.id} has too few challenges');
        expect(quest.starReward, greaterThan(0));

        for (final challenge in quest.challenges) {
          expect(challenge.prompt, isNotEmpty);
          // Embedded mini-game sessions generate questions at play
          // time; their fixed options are engine bookkeeping.
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
          if (challenge is MemoryChallenge) {
            expect(challenge.itemsToRemember, isNotEmpty);
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

    test('every world ends in one boss quest at its final location', () {
      for (final world in Worlds.all) {
        final bosses =
            QuestCatalog.all.where((q) => q.starReward >= 3).where((q) =>
                world.locations.any((l) => l.id == q.locationId));
        expect(bosses.length, 1,
            reason: '${world.name} must have exactly one boss quest');
        final boss = bosses.single;
        expect(boss.locationId, world.locations.last.id,
            reason: "${world.name}'s boss must live at its final "
                'location');
        expect(boss.challenges.length, 4);
        expect(boss.npc, isNotNull);
        expect(boss.introDialogue.length, greaterThanOrEqualTo(3));
        expect(boss.resolutionSteps.length, greaterThanOrEqualTo(3));
      }
    });

    test('Memory Master embeds stay jungle-only', () {
      // Its generated rounds say "jungle friends", so other worlds
      // author their own MemoryChallenge moments instead.
      for (final quest in QuestCatalog.all) {
        if (quest.challenges.any((c) => c is MemoryMasterChallenge)) {
          expect(
            JungleWorld.locations.map((l) => l.id),
            contains(quest.locationId),
            reason: 'Quest ${quest.id} embeds Memory Master outside '
                'the jungle',
          );
        }
      }
    });

    test('star economy makes every location in every world reachable '
        'from base rewards alone', () {
      final allLocations = Worlds.all.expand((w) => w.locations).toList();
      for (final location in allLocations) {
        final earnableBefore = allLocations
            .where((l) => l.requiredStars < location.requiredStars)
            .expand((l) => QuestCatalog.forLocation(l.id))
            .fold<int>(0, (sum, quest) => sum + quest.starReward);

        expect(earnableBefore, greaterThanOrEqualTo(location.requiredStars),
            reason: '${location.name} needs ${location.requiredStars} '
                'stars but only $earnableBefore are earnable before it');
      }
    });
  });
}
