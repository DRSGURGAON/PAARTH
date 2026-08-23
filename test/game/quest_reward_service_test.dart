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
}
