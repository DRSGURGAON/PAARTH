import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/data/badge_catalog.dart';
import 'package:super_kid_adventure/game/quests/jungle_quests.dart';
import 'package:super_kid_adventure/game/quests/quest_catalog.dart';
import 'package:super_kid_adventure/game/repositories/mini_game_repository.dart';

void main() {
  group('BadgeCatalog', () {
    const empty = BadgeStats(
      completedQuestIds: {},
      miniGameStarIds: {},
      totalStars: 0,
      totalCoins: 0,
    );

    test('badge ids are unique', () {
      final ids = BadgeCatalog.all.map((b) => b.id).toList();

      expect(ids.toSet().length, ids.length);
    });

    test('nothing is earned with zero progress', () {
      expect(BadgeCatalog.earnedBadgeIds(empty), isEmpty);
    });

    test('first_quest earns after completing one quest', () {
      final stats = BadgeStats(
        completedQuestIds: {JungleQuests.all.first.id},
        miniGameStarIds: const {},
        totalStars: 2,
        totalCoins: 6,
      );

      expect(BadgeCatalog.earnedBadgeIds(stats), contains('first_quest'));
      expect(
        BadgeCatalog.earnedBadgeIds(stats),
        isNot(contains('jungle_explorer')),
      );
    });

    test('jungle_explorer requires every Jungle quest completed', () {
      final allIds = JungleQuests.all.map((q) => q.id).toSet();
      final almostAll = allIds.toList()..removeLast();

      final partial = BadgeStats(
        completedQuestIds: almostAll.toSet(),
        miniGameStarIds: const {},
        totalStars: 0,
        totalCoins: 0,
      );
      final complete = BadgeStats(
        completedQuestIds: allIds,
        miniGameStarIds: const {},
        totalStars: 0,
        totalCoins: 0,
      );

      expect(
        BadgeCatalog.earnedBadgeIds(partial),
        isNot(contains('jungle_explorer')),
      );
      expect(BadgeCatalog.earnedBadgeIds(complete), contains('jungle_explorer'));
    });

    test("each world's explorer badge needs that world's own quests, "
        'not just any matching count', () {
      // All jungle quests done: jungle_explorer only, even though the
      // completed count exceeds any single world's quest count.
      final jungleDone = BadgeStats(
        completedQuestIds: JungleQuests.all.map((q) => q.id).toSet(),
        miniGameStarIds: const {},
        totalStars: 0,
        totalCoins: 0,
      );

      final earned = BadgeCatalog.earnedBadgeIds(jungleDone);
      expect(earned, contains('jungle_explorer'));
      expect(earned, isNot(contains('space_explorer')));
      expect(earned, isNot(contains('dino_explorer')));
      expect(earned, isNot(contains('magic_explorer')));
      expect(earned, isNot(contains('robot_explorer')));
    });

    test('each mini-game badge tracks its own game id only', () {
      const stats = BadgeStats(
        completedQuestIds: {},
        miniGameStarIds: {MiniGameIds.mathDash},
        totalStars: 0,
        totalCoins: 0,
      );

      final earned = BadgeCatalog.earnedBadgeIds(stats);
      expect(earned, contains('math_whiz'));
      expect(earned, isNot(contains('memory_master_badge')));
      expect(earned, isNot(contains('pattern_pro')));
      expect(earned, isNot(contains('word_wizard')));
      expect(earned, isNot(contains('eagle_eye')));
      expect(earned, isNot(contains('lightning_kid')));
    });

    test('lightning_kid tracks the Quick Challenge star', () {
      const stats = BadgeStats(
        completedQuestIds: {},
        miniGameStarIds: {MiniGameIds.quickChallenge},
        totalStars: 0,
        totalCoins: 0,
      );

      expect(BadgeCatalog.earnedBadgeIds(stats), contains('lightning_kid'));
    });

    test('star_collector and coin_collector have independent thresholds',
        () {
      const starsOnly = BadgeStats(
        completedQuestIds: {},
        miniGameStarIds: {},
        totalStars: 20,
        totalCoins: 0,
      );
      const coinsOnly = BadgeStats(
        completedQuestIds: {},
        miniGameStarIds: {},
        totalStars: 0,
        totalCoins: 20,
      );
      const neither = BadgeStats(
        completedQuestIds: {},
        miniGameStarIds: {},
        totalStars: 19,
        totalCoins: 19,
      );

      expect(BadgeCatalog.earnedBadgeIds(starsOnly), contains('star_collector'));
      expect(
        BadgeCatalog.earnedBadgeIds(starsOnly),
        isNot(contains('coin_collector')),
      );
      expect(BadgeCatalog.earnedBadgeIds(coinsOnly), contains('coin_collector'));
      expect(BadgeCatalog.earnedBadgeIds(neither), isEmpty);
    });

    test('super_kid is earned only once every other badge is earned', () {
      final allQuestIds = QuestCatalog.all.map((q) => q.id).toSet();
      final everything = BadgeStats(
        completedQuestIds: allQuestIds,
        miniGameStarIds: MiniGameIds.all.toSet(),
        totalStars: 20,
        totalCoins: 20,
      );
      final missingOne = BadgeStats(
        completedQuestIds: allQuestIds,
        miniGameStarIds: MiniGameIds.all.toSet(),
        totalStars: 20,
        totalCoins: 0, // coin_collector not earned
      );

      final earnedEverything = BadgeCatalog.earnedBadgeIds(everything);
      expect(earnedEverything, contains('super_kid'));
      expect(earnedEverything.length, BadgeCatalog.all.length);

      expect(
        BadgeCatalog.earnedBadgeIds(missingOne),
        isNot(contains('super_kid')),
      );
    });
  });
}
