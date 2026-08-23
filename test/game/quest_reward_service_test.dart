import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/systems/quest_reward_service.dart';

void main() {
  group('QuestRewardService', () {
    test('a perfect run earns the bonus star and the perfect coin payout',
        () {
      final reward = QuestRewardService.calculate(
          baseStarReward: 2, wrongAttempts: 0);

      expect(reward.stars, 2 + QuestRewardService.perfectBonusStars);
      expect(reward.coins, QuestRewardService.perfectCoins);
    });

    test('any number of retries pays the same gentle non-bonus tier', () {
      for (final attempts in [1, 2, 10]) {
        final reward = QuestRewardService.calculate(
            baseStarReward: 2, wrongAttempts: attempts);

        expect(reward.stars, 2, reason: '$attempts retries');
        expect(reward.coins, QuestRewardService.coinsWithRetries,
            reason: '$attempts retries');
      }
    });

    test('retries are never punished below the base reward', () {
      final reward = QuestRewardService.calculate(
          baseStarReward: 2, wrongAttempts: 99);

      expect(reward.stars, greaterThanOrEqualTo(2));
      expect(reward.coins, greaterThan(0));
    });
  });

  group('QuestRewardService.calculateMathDash', () {
    test('the star threshold is ~80% of the session, rounded up', () {
      expect(QuestRewardService.mathDashStarThreshold(5), 4);
      expect(QuestRewardService.mathDashStarThreshold(3), 3);
    });

    test('a perfect session pays the star plus the perfect-streak bonus', () {
      final reward = QuestRewardService.calculateMathDash(
          correctAnswers: 5, totalQuestions: 5, bestStreak: 5);

      expect(reward.stars, 1);
      expect(
          reward.coins,
          QuestRewardService.mathDashCoins +
              QuestRewardService.perfectStreakBonusCoins);
    });

    test('reaching the threshold with a mid streak pays star + small bonus',
        () {
      final reward = QuestRewardService.calculateMathDash(
          correctAnswers: 4, totalQuestions: 5, bestStreak: 3);

      expect(reward.stars, 1);
      expect(
          reward.coins,
          QuestRewardService.mathDashCoins +
              QuestRewardService.streakBonusCoins);
    });

    test('below the threshold: no star, and a streak still earns a little',
        () {
      final noStreak = QuestRewardService.calculateMathDash(
          correctAnswers: 3, totalQuestions: 5, bestStreak: 2);
      final withStreak = QuestRewardService.calculateMathDash(
          correctAnswers: 3, totalQuestions: 5, bestStreak: 3);

      expect(noStreak.stars, 0);
      expect(noStreak.coins, 0);
      expect(withStreak.stars, 0);
      expect(withStreak.coins, QuestRewardService.streakBonusCoins);
    });

    test('nothing is ever negative, even with zero correct', () {
      final reward = QuestRewardService.calculateMathDash(
          correctAnswers: 0, totalQuestions: 5, bestStreak: 0);

      expect(reward.stars, 0);
      expect(reward.coins, 0);
    });
  });
}
