import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/quests/jungle_quests.dart';
import 'package:super_kid_adventure/game/repositories/coin_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';
import 'package:super_kid_adventure/game/repositories/quest_repository.dart';
import 'package:super_kid_adventure/game/systems/quest_engine.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('QuestEngine', () {
    late FakeLocalStorageService storage;
    late ProgressRepository progressRepository;
    late QuestRepository questRepository;
    late CoinRepository coinRepository;

    QuestEngine buildEngine() => QuestEngine(
          quest: JungleQuests.all.first,
          progressRepository: progressRepository,
          questRepository: questRepository,
          coinRepository: coinRepository,
        );

    Future<void> playToCompletion(QuestEngine engine) async {
      while (!engine.isComplete) {
        await engine.submitAnswer(engine.currentChallenge.correctIndex);
      }
    }

    setUp(() {
      storage = FakeLocalStorageService();
      progressRepository = ProgressRepository(storage);
      questRepository = QuestRepository(storage);
      coinRepository = CoinRepository(storage);
    });

    test('correct answers advance and finally complete the quest', () async {
      final engine = buildEngine();
      final quest = engine.quest;

      for (var i = 0; i < quest.challenges.length - 1; i++) {
        final result = await engine
            .submitAnswer(quest.challenges[i].correctIndex);
        expect(result, AnswerResult.advanced);
        expect(engine.currentIndex, i + 1);
      }

      final finalResult = await engine
          .submitAnswer(quest.challenges.last.correctIndex);
      expect(finalResult, AnswerResult.completed);
      expect(engine.isComplete, isTrue);
    });

    test('a wrong answer does not advance and rotates encouragement',
        () async {
      final engine = buildEngine();
      final wrongIndex =
          (engine.currentChallenge.correctIndex + 1) %
              engine.currentChallenge.options.length;

      final result = await engine.submitAnswer(wrongIndex);

      expect(result, AnswerResult.incorrect);
      expect(engine.currentIndex, 0);
      expect(engine.nextEncouragement(), QuestEngine.encouragements[0]);
      expect(progressRepository.stars, 0);
    });

    test(
        'first completion awards stars and coins and marks the quest '
        'completed', () async {
      final engine = buildEngine();

      await playToCompletion(engine);

      expect(engine.starsAwarded, engine.quest.starReward);
      expect(engine.coinsAwarded,
          engine.quest.starReward * QuestEngine.coinsPerStar);
      expect(progressRepository.stars, engine.quest.starReward);
      expect(coinRepository.coins, engine.coinsAwarded);
      expect(questRepository.isCompleted(engine.quest.id), isTrue);
    });

    test('replaying a completed quest awards no additional stars or coins',
        () async {
      await playToCompletion(buildEngine());
      final starsAfterFirstClear = progressRepository.stars;
      final coinsAfterFirstClear = coinRepository.coins;

      final replay = buildEngine();
      await playToCompletion(replay);

      expect(replay.starsAwarded, 0);
      expect(replay.coinsAwarded, 0);
      expect(progressRepository.stars, starsAfterFirstClear);
      expect(coinRepository.coins, coinsAfterFirstClear);
    });
  });
}
