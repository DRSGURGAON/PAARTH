import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/data/companion_catalog.dart';
import 'package:super_kid_adventure/game/repositories/mini_game_repository.dart';

void main() {
  group('CompanionCatalog', () {
    test('companion ids are unique', () {
      final ids = CompanionCatalog.all.map((c) => c.id).toList();

      expect(ids.toSet().length, ids.length);
    });

    test('there is exactly one companion per built mini-game', () {
      final unlockGameIds =
          CompanionCatalog.all.map((c) => c.unlockMiniGameId).toSet();

      expect(unlockGameIds, MiniGameIds.all.toSet());
    });

    test('nothing is unlocked with zero mini-game stars', () {
      expect(CompanionCatalog.unlockedCompanionIds(const {}), isEmpty);
    });

    test('earning a star in one mini-game unlocks only its companion', () {
      final unlocked = CompanionCatalog.unlockedCompanionIds(
        {MiniGameIds.mathDash},
      );

      expect(unlocked, {CompanionIds.robot});
    });

    test('each companion tracks its own mini-game only', () {
      final unlocked = CompanionCatalog.unlockedCompanionIds({
        MiniGameIds.patternPower,
        MiniGameIds.memoryMaster,
      });

      expect(unlocked, {CompanionIds.fox, CompanionIds.panda});
    });

    test('earning every mini-game star unlocks every companion', () {
      final unlocked =
          CompanionCatalog.unlockedCompanionIds(MiniGameIds.all.toSet());

      expect(unlocked, CompanionIds.all.toSet());
    });
  });
}
