import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/repositories/mini_game_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('MiniGameRepository', () {
    test('starEarnedGameIds is empty when nothing is saved', () {
      final repository = MiniGameRepository(FakeLocalStorageService());

      expect(repository.starEarnedGameIds(), isEmpty);
    });

    test('markStarEarned() records the id and is idempotent', () async {
      final repository = MiniGameRepository(FakeLocalStorageService());

      await repository.markStarEarned(MiniGameIds.mathDash);
      await repository.markStarEarned(MiniGameIds.mathDash);
      await repository.markStarEarned(MiniGameIds.memoryMaster);

      expect(
        repository.starEarnedGameIds(),
        {MiniGameIds.mathDash, MiniGameIds.memoryMaster},
      );
    });

    test('persists across repository instances', () async {
      final storage = FakeLocalStorageService();
      await MiniGameRepository(storage).markStarEarned(MiniGameIds.wordBuilder);

      final fresh = MiniGameRepository(storage);
      expect(fresh.starEarnedGameIds(), {MiniGameIds.wordBuilder});
    });

    test('MiniGameIds.all lists exactly the 6 built mini-games', () {
      expect(MiniGameIds.all, [
        MiniGameIds.mathDash,
        MiniGameIds.memoryMaster,
        MiniGameIds.patternPower,
        MiniGameIds.wordBuilder,
        MiniGameIds.findDiscover,
        MiniGameIds.quickChallenge,
      ]);
    });
  });
}
