/// Educational subject of a challenge. Tracked per-challenge so the
/// adaptive difficulty system (later phase) and the Parent Zone
/// (Phase 10) can report progress per subject.
enum ChallengeCategory { math, logic, memory, english }

/// One tappable-answer challenge inside a quest — the Phase 3 "default"
/// challenge type. Richer mini-game challenge types (Math Dash, Memory
/// Master, ...) arrive in Phases 4–6 and plug into the same quest flow.
class ChoiceChallenge {
  const ChoiceChallenge({
    required this.category,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.visual,
    this.rewardLabel,
  });

  final ChallengeCategory category;

  /// Short, story-framed question ("The monkey eats 3. How many are left?").
  final String prompt;

  /// Optional emoji line shown large above the prompt, so the child can
  /// count/see objects instead of reading bare digits.
  final String? visual;

  final List<String> options;
  final int correctIndex;

  /// Story item earned by solving this challenge ("Bridge Piece 1").
  /// Null means the challenge flows straight into the next step.
  final String? rewardLabel;

  bool isCorrect(int optionIndex) => optionIndex == correctIndex;
}

/// A story-driven quest attached to one map location: intro → a run of
/// challenges → outro + star reward. Pure data, declared in
/// `game/quests/` content files.
class Quest {
  const Quest({
    required this.id,
    required this.locationId,
    required this.title,
    required this.storyIntro,
    required this.storyOutro,
    required this.starReward,
    required this.challenges,
  });

  final String id;
  final String locationId;
  final String title;
  final String storyIntro;
  final String storyOutro;

  /// Stars awarded the first time this quest is completed. Replays are
  /// allowed (practice is good!) but award nothing again.
  final int starReward;

  final List<ChoiceChallenge> challenges;
}
