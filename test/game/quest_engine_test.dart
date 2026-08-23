import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/quests/jungle_quests.dart';
import 'package:super_kid_adventure/game/repositories/coin_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';
import 'package:super_kid_adventure/game/repositories/quest_progress_repository.dart';
import 'package:super_kid_adventure/game/repositories/quest_repository.dart';
import 'package:super_kid_adventure/game/systems/quest_engine.dart';
import 'package:super_kid_adventure/game/systems/quest_reward_service.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('QuestEngine', () {
    late FakeLocalStorageService storage;
    late ProgressRepository progressRepository;
    late QuestRepository questRepository;
    late CoinRepository coinRepository;
    late QuestProgressRepository questProgressRepository;

    QuestEngine buildEngine() => QuestEngine(
          quest: JungleQuests.all.first,
          progressRepository: progressRepository,
          questRepository: questRepository,
          coinRepository: coinRepository,
          questProgressRepository: questProgressRepository,
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
      questProgressRepository = QuestProgressRepository(storage);
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

    test('a perfect first clear pays the bonus star and perfect coins',
        () async {
      final engine = buildEngine();

      await playToCompletion(engine);

      final expected = QuestRewardService.calculate(
          baseStarReward: engine.quest.starReward, wrongAttempts: 0);
      expect(engine.starsAwarded, expected.stars);
      expect(engine.coinsAwarded, QuestRewardService.perfectCoins);
      expect(progressRepository.stars, expected.stars);
      expect(coinRepository.coins, expected.coins);
      expect(questRepository.isCompleted(engine.quest.id), isTrue);
      expect(questRepository.starsEarnedFor(engine.quest.id), expected.stars);
    });

    test('a first clear with retries pays base stars and the retry coins',
        () async {
      final engine = buildEngine();
      final wrongIndex =
          (engine.currentChallenge.correctIndex + 1) %
              engine.currentChallenge.options.length;
      await engine.submitAnswer(wrongIndex);

      await playToCompletion(engine);

      expect(engine.starsAwarded, engine.quest.starReward);
      expect(engine.coinsAwarded, QuestRewardService.coinsWithRetries);
      // Retrying never deducts anything — the payout is simply the
      // non-bonus tier.
      expect(progressRepository.stars, engine.quest.starReward);
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

    test('a mid-quest run persists and a fresh engine resumes it', () async {
      final engine = buildEngine();
      final wrongIndex =
          (engine.currentChallenge.correctIndex + 1) %
              engine.currentChallenge.options.length;
      await engine.submitAnswer(wrongIndex);
      await engine.submitAnswer(engine.currentChallenge.correctIndex);
      expect(engine.currentIndex, 1);

      // A brand-new engine (fresh screen, or a full app restart) picks
      // up at the start of the current challenge, misses included.
      final resumed = buildEngine();
      expect(resumed.currentIndex, 1);
      expect(resumed.wrongAttempts, 1);

      // The saved misses still decide the reward tier after resuming.
      await playToCompletion(resumed);
      expect(resumed.coinsAwarded, QuestRewardService.coinsWithRetries);
    });

    test('completion clears the saved run', () async {
      final engine = buildEngine();
      await playToCompletion(engine);

      expect(questProgressRepository.load(), isNull);
      expect(buildEngine().currentIndex, 0);
    });

    test('a saved run for a different quest does not leak into this one',
        () async {
      await questProgressRepository.save(const QuestProgress(
        questId: 'some_other_quest',
        challengeIndex: 2,
        wrongAttempts: 5,
      ));

      final engine = buildEngine();

      expect(engine.currentIndex, 0);
      expect(engine.wrongAttempts, 0);
    });
  });
}
