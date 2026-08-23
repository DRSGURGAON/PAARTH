import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/quest_state.dart';
import 'package:super_kid_adventure/game/repositories/quest_progress_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('QuestProgressRepository', () {
    test('load() returns null when nothing is saved', () {
      expect(QuestProgressRepository(FakeLocalStorageService()).load(), isNull);
    });

    test('save() then load() round-trips a run', () async {
      final repository = QuestProgressRepository(FakeLocalStorageService());

      await repository.save(const QuestProgress(
        questId: 'jungle_bridge_repair',
        challengeIndex: 2,
        wrongAttempts: 1,
      ));
      final loaded = repository.load();

      expect(loaded, isNotNull);
      expect(loaded!.questId, 'jungle_bridge_repair');
      expect(loaded.challengeIndex, 2);
      expect(loaded.wrongAttempts, 1);
    });

    test('clear() removes the saved run', () async {
      final repository = QuestProgressRepository(FakeLocalStorageService());
      await repository.save(const QuestProgress(
          questId: 'q', challengeIndex: 0, wrongAttempts: 0));

      await repository.clear();

      expect(repository.load(), isNull);
    });

    test('load() returns null on corrupted save data', () async {
      final storage = FakeLocalStorageService();
      await storage.setString('quest_progress_v1', 'not valid json {');

      expect(QuestProgressRepository(storage).load(), isNull);
    });
  });

  group('resolveQuestState', () {
    test('derives each state from the underlying facts', () {
      QuestState resolve({
        bool unlocked = true,
        Set<String> completed = const {},
        String? inProgress,
      }) =>
          resolveQuestState(
            questId: 'q1',
            locationUnlocked: unlocked,
            completedQuestIds: completed,
            inProgressQuestId: inProgress,
          );

      expect(resolve(unlocked: false), QuestState.locked);
      expect(resolve(), QuestState.available);
      expect(resolve(inProgress: 'q1'), QuestState.inProgress);
      expect(resolve(inProgress: 'other'), QuestState.available);
      expect(resolve(completed: {'q1'}), QuestState.completed);
      // Completed wins even over a stale in-progress slot or a lock —
      // a finished quest can never regress.
      expect(resolve(completed: {'q1'}, inProgress: 'q1'),
          QuestState.completed);
      expect(resolve(completed: {'q1'}, unlocked: false),
          QuestState.completed);
    });
  });
}
