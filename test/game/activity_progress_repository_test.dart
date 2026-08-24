import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/activity_progress.dart';
import 'package:super_kid_adventure/game/repositories/activity_progress_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('ActivityProgressRepository', () {
    test('an unplayed activity loads sensible defaults', () {
      final repository = ActivityProgressRepository(FakeLocalStorageService());

      final progress = repository.load(ActivityIds.chess);

      expect(progress.sessionsCompleted, 0);
      expect(progress.achievements, isEmpty);
      expect(progress.skillLevel, 1);
    });

    test('sessions, achievements, and skill level round-trip per activity',
        () async {
      final repository = ActivityProgressRepository(FakeLocalStorageService());

      await repository.recordSessionCompleted(ActivityIds.chess);
      await repository.recordSessionCompleted(ActivityIds.chess);
      await repository.addAchievement(ActivityIds.chess, 'chess_first_win');
      await repository.setSkillLevel(ActivityIds.chess, 3);
      await repository.recordSessionCompleted(ActivityIds.piano);

      final chess = repository.load(ActivityIds.chess);
      expect(chess.sessionsCompleted, 2);
      expect(chess.achievements, {'chess_first_win'});
      expect(chess.skillLevel, 3);
      // Other activities are untouched.
      expect(repository.load(ActivityIds.piano).sessionsCompleted, 1);
      expect(repository.load(ActivityIds.guitar).sessionsCompleted, 0);
    });

    test('addAchievement reports whether it was newly earned', () async {
      final repository = ActivityProgressRepository(FakeLocalStorageService());

      expect(await repository.addAchievement(ActivityIds.piano, 'song_x'),
          isTrue);
      expect(await repository.addAchievement(ActivityIds.piano, 'song_x'),
          isFalse);
    });

    test('corrupted data degrades to defaults instead of throwing', () async {
      final storage = FakeLocalStorageService();
      await storage.setString('activity_progress_v1', 'not valid json {');
      final repository = ActivityProgressRepository(storage);

      expect(repository.load(ActivityIds.guitar).sessionsCompleted, 0);

      // And a new write heals the blob.
      await repository.recordSessionCompleted(ActivityIds.guitar);
      expect(repository.load(ActivityIds.guitar).sessionsCompleted, 1);
    });
  });
}
