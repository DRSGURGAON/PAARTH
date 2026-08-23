/// What one quest completion actually pays out.
class QuestReward {
  const QuestReward({required this.stars, required this.coins});

  final int stars;
  final int coins;
}

/// What one standalone mini-game session actually pays out.
class MiniGameReward {
  const MiniGameReward({required this.stars, required this.coins});

  final int stars;
  final int coins;
}

/// The single place reward math lives (brief section 14) — never
/// calculated ad hoc in UI code. Quests: a perfect run (no wrong
/// answers at all) earns a bonus star and bigger coin payout; a run
/// with retries still pays well, because retrying is learning, not
/// failing. Mini-games report their performance here and this service
/// decides the payout. Nothing is ever deducted for a wrong answer.
class QuestRewardService {
  QuestRewardService._();

  static const int perfectBonusStars = 1;
  static const int perfectCoins = 50;
  static const int coinsWithRetries = 35;

  /// Math Dash payout constants: the star needs ~80% first-try correct;
  /// coins are modest next to quest payouts (a session is much shorter
  /// than a quest); streaks add a small bonus, never a penalty.
  static const int mathDashCoins = 5;
  static const int streakBonusCoins = 1;
  static const int perfectStreakBonusCoins = 3;

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

  /// First-try correct answers needed for a session of [totalQuestions]
  /// to earn its star (ceil of 80% — 4 of 5).
  static int mathDashStarThreshold(int totalQuestions) =>
      (totalQuestions * 4 + 4) ~/ 5;

  static MiniGameReward calculateMathDash({
    required int correctAnswers,
    required int totalQuestions,
    required int bestStreak,
  }) {
    final earnedStar = correctAnswers >= mathDashStarThreshold(totalQuestions);
    var coins = earnedStar ? mathDashCoins : 0;
    if (bestStreak >= totalQuestions) {
      coins += perfectStreakBonusCoins;
    } else if (bestStreak >= 3) {
      coins += streakBonusCoins;
    }
    return MiniGameReward(stars: earnedStar ? 1 : 0, coins: coins);
  }
}
