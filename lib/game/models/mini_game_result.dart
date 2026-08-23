/// The outcome of one mini-game session (Math Dash, Memory Master),
/// handed back to whoever launched it — the results screen in
/// standalone play, or the Quest Engine when a quest embedded the
/// session as a challenge. Pure data; reward *decisions* live in
/// `QuestRewardService`, and the awarded fields here only record what
/// was actually paid out (always 0 in quest-embedded sessions, where
/// the quest's own completion pays).
class MiniGameSessionResult {
  const MiniGameSessionResult({
    required this.completed,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.bestStreak,
    required this.starsAwarded,
    required this.coinsAwarded,
    required this.level,
  });

  final bool completed;

  /// First-try correct answers (retries still finish the session but
  /// don't count toward the score).
  final int correctAnswers;
  final int totalQuestions;
  final int bestStreak;
  final int starsAwarded;
  final int coinsAwarded;

  /// Difficulty level the session was played at.
  final int level;
}
