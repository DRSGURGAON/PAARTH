import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/repositories/quest_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('QuestRepository', () {
    test('markCompleted records completion and the stars actually earned',
        () async {
      final repository = QuestRepository(FakeLocalStorageService());

      await repository.markCompleted('q1', starsEarned: 3);

      expect(repository.isCompleted('q1'), isTrue);
      expect(repository.starsEarnedFor('q1'), 3);
      expect(repository.starsEarnedFor('q2'), isNull);
    });

    test('a completion saved without stars (older saves) reads back null, '
        'not zero', () async {
      final repository = QuestRepository(FakeLocalStorageService());

      await repository.markCompleted('old_quest');

      expect(repository.isCompleted('old_quest'), isTrue);
      expect(repository.starsEarnedFor('old_quest'), isNull);
    });

    test('corrupted stars data degrades to null instead of throwing',
        () async {
      final storage = FakeLocalStorageService();
      await storage.setString('quest_stars_v1', 'not valid json {');
      final repository = QuestRepository(storage);

      expect(repository.starsEarnedFor('q1'), isNull);

      // And a new record heals the corrupted blob.
      await repository.markCompleted('q1', starsEarned: 2);
      expect(repository.starsEarnedFor('q1'), 2);
    });
  });
}
