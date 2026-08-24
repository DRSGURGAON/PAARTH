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

  /// Mini-game session payout constants (Math Dash, Memory Master, and
  /// any future session-based mini-game): the star needs ~80% first-try
  /// correct; coins are modest next to quest payouts (a session is much
  /// shorter than a quest); streaks add a small bonus, never a penalty.
  static const int sessionCoins = 5;
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
  static int sessionStarThreshold(int totalQuestions) =>
      (totalQuestions * 4 + 4) ~/ 5;

  /// One payout rule for every session-based mini-game — Math Dash and
  /// Memory Master both report performance here rather than computing
  /// rewards themselves.
  static MiniGameReward calculateMiniGameSession({
    required int correctAnswers,
    required int totalQuestions,
    required int bestStreak,
  }) {
    final earnedStar = correctAnswers >= sessionStarThreshold(totalQuestions);
    var coins = earnedStar ? sessionCoins : 0;
    if (bestStreak >= totalQuestions) {
      coins += perfectStreakBonusCoins;
    } else if (bestStreak >= 3) {
      coins += streakBonusCoins;
    }
    return MiniGameReward(stars: earnedStar ? 1 : 0, coins: coins);
  }

  /// Chess Club match payout (activities brief section 11): win ⭐⭐⭐,
  /// draw ⭐⭐, and finishing a match always pays ⭐ — losing never pays
  /// zero, because playing a whole game *is* the learning.
  static MiniGameReward calculateChessMatch({
    required bool won,
    required bool drawn,
  }) {
    if (won) return const MiniGameReward(stars: 3, coins: 10);
    if (drawn) return const MiniGameReward(stars: 2, coins: 6);
    return const MiniGameReward(stars: 1, coins: 3);
  }

  /// First-time completion of a Piano/Guitar song (activities brief
  /// section 17). Replays stay free-play fun with no farming loop —
  /// callers award this only when the song achievement is newly earned.
  static const MiniGameReward songCompletionReward =
      MiniGameReward(stars: 1, coins: 3);
}
