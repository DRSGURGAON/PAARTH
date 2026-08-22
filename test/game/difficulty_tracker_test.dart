import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/quest.dart';
import 'package:super_kid_adventure/game/systems/difficulty_tracker.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('DifficultyTracker', () {
    late FakeLocalStorageService storage;
    late DifficultyTracker tracker;

    setUp(() {
      storage = FakeLocalStorageService();
      tracker = DifficultyTracker(storage);
    });

    Future<void> record(int count, {required bool correct}) async {
      for (var i = 0; i < count; i++) {
        await tracker.recordResult(ChallengeCategory.math, correct: correct);
      }
    }

    test('starts at the minimum level', () {
      expect(tracker.levelFor(ChallengeCategory.math),
          DifficultyTracker.minLevel);
    });

    test('3 correct answers in a row level up', () async {
      await record(2, correct: true);
      expect(tracker.levelFor(ChallengeCategory.math), 1);

      await record(1, correct: true);
      expect(tracker.levelFor(ChallengeCategory.math), 2);
    });

    test('level never exceeds the maximum', () async {
      await record(100, correct: true);

      expect(tracker.levelFor(ChallengeCategory.math),
          DifficultyTracker.maxLevel);
    });

    test('2 misses in a row level down, never below the minimum', () async {
      await record(3, correct: true); // reach level 2
      await record(2, correct: false);
      expect(tracker.levelFor(ChallengeCategory.math), 1);

      await record(10, correct: false);
      expect(tracker.levelFor(ChallengeCategory.math),
          DifficultyTracker.minLevel);
    });

    test('a wrong answer resets the correct streak', () async {
      await record(2, correct: true);
      await record(1, correct: false);
      await record(2, correct: true);

      // Streak was broken, so still level 1 after only 2 new corrects.
      expect(tracker.levelFor(ChallengeCategory.math), 1);
    });

    test('categories are tracked independently', () async {
      await record(3, correct: true);

      expect(tracker.levelFor(ChallengeCategory.math), 2);
      expect(tracker.levelFor(ChallengeCategory.logic), 1);
    });

    test('levels persist across tracker instances', () async {
      await record(3, correct: true);

      final fresh = DifficultyTracker(storage);
      expect(fresh.levelFor(ChallengeCategory.math), 2);
    });
  });
}
