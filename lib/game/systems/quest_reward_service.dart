/// What one quest completion actually pays out.
class QuestReward {
  const QuestReward({required this.stars, required this.coins});

  final int stars;
  final int coins;
}

/// The single place quest reward math lives (brief section 14) — never
/// calculated ad hoc in UI code. A perfect run (no wrong answers at
/// all) earns a bonus star and bigger coin payout; a run with retries
/// still pays well, because retrying is learning, not failing. Nothing
/// is ever deducted for a wrong answer.
class QuestRewardService {
  QuestRewardService._();

  static const int perfectBonusStars = 1;
  static const int perfectCoins = 50;
  static const int coinsWithRetries = 35;

  static QuestReward calculate({
    required int baseStarReward,
    required int wrongAttempts,
  }) {
    final perfect = wrongAttempts == 0;
    return QuestReward(
      stars: perfect ? baseStarReward + perfectBonusStars : baseStarReward,
      coins: perfect ? perfectCoins : coinsWithRetries,
    );
  }
}
