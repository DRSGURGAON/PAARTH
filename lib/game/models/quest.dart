/// Educational subject of a challenge. Tracked per-challenge so the
/// adaptive difficulty system (later phase) and the Parent Zone
/// (Phase 10) can report progress per subject.
enum ChallengeCategory { math, logic, memory, english }

/// The friendly character who narrates a quest's story ("Momo the
/// Monkey"). Pure data — an emoji stands in for real character art
/// until production assets exist (see the README's Assets section).
class QuestNpc {
  const QuestNpc({required this.name, required this.emoji});

  final String name;
  final String emoji;
}

/// Common shape of every challenge inside a quest: a tappable-answer
/// prompt with options, an optional gentle hint shown after a miss, and
/// an optional story item earned on success. Subtypes add their own
/// presentation data ([ChoiceChallenge]'s emoji visual,
/// [MemoryChallenge]'s study phase); richer mini-game challenge types
/// (Math Dash, Memory Master, ...) are full separate games from Phases
/// 4–6 that award through the same star/coin repositories.
sealed class QuestChallenge {
  const QuestChallenge({
    required this.category,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.hint,
    this.rewardLabel,
  });

  final ChallengeCategory category;

  /// Short, story-framed question ("The monkey eats 3. How many are left?").
  final String prompt;

  final List<String> options;
  final int correctIndex;

  /// Gentle nudge shown after a wrong answer ("Count the bananas one by
  /// one!"). Never the answer itself, never shaming.
  final String? hint;

  /// Story item earned by solving this challenge ("Bridge Piece #1").
  /// Null means the challenge flows straight into the next step.
  final String? rewardLabel;

  bool isCorrect(int optionIndex) => optionIndex == correctIndex;
}

/// The default challenge type: an optional emoji visual above the
/// prompt so the child can count/see objects instead of reading bare
/// digits.
class ChoiceChallenge extends QuestChallenge {
  const ChoiceChallenge({
    required super.category,
    required super.prompt,
    required super.options,
    required super.correctIndex,
    super.hint,
    super.rewardLabel,
    this.visual,
  });

  /// Optional emoji line shown large above the prompt.
  final String? visual;
}

/// A short remember-then-answer challenge: [itemsToRemember] is shown
/// big, the child taps "I'm ready!", the items hide, and the options
/// appear. Kept deliberately gentle for a 7-year-old — the child
/// controls when the study phase ends, there is no timer.
class MemoryChallenge extends QuestChallenge {
  const MemoryChallenge({
    required super.prompt,
    required super.options,
    required super.correctIndex,
    required this.itemsToRemember,
    super.hint,
    super.rewardLabel,
    this.studyPrompt = 'Remember these jungle friends!',
  }) : super(category: ChallengeCategory.memory);

  /// Emoji line to memorize ("🐒 🐼 🦊 🐰").
  final String itemsToRemember;

  /// Instruction shown during the study phase.
  final String studyPrompt;
}

/// A story-driven quest attached to one map location: intro dialogue →
/// a run of challenges → an optional animated story resolution → outro
/// + rewards. Pure data, declared in `game/quests/` content files, so
/// future quests ("Rescue the Baby Monkey", "Find the Lost Treasure",
/// ...) are added by appending data — never by touching the engine or
/// the screens.
class Quest {
  const Quest({
    required this.id,
    required this.locationId,
    required this.title,
    required this.storyIntro,
    required this.storyOutro,
    required this.starReward,
    required this.challenges,
    this.npc,
    this.introDialogue = const [],
    this.resolutionSteps = const [],
  });

  final String id;
  final String locationId;
  final String title;

  /// One-paragraph fallback intro, used when [introDialogue] is empty.
  final String storyIntro;
  final String storyOutro;

  /// Base stars awarded on this quest's first completion (a perfect
  /// first-try run earns a bonus — see QuestRewardService). Replays are
  /// allowed (practice is good!) but award nothing again.
  final int starReward;

  final List<QuestChallenge> challenges;

  /// Who tells this quest's story. Null falls back to a generic
  /// storybook presentation.
  final QuestNpc? npc;

  /// Short dialogue lines shown one at a time before the quest starts
  /// ("Uh-oh!", "The jungle bridge is broken!", ...). Empty means the
  /// intro shows [storyIntro] as a single step instead.
  final List<String> introDialogue;

  /// Story-resolution beats played after the last challenge ("The
  /// bridge pieces float into place!", ...) so the child sees their
  /// challenge rewards directly fixing the story problem. Empty skips
  /// straight to the completion celebration.
  final List<String> resolutionSteps;

  /// The dialogue the intro screen should play.
  List<String> get effectiveIntroDialogue =>
      introDialogue.isEmpty ? [storyIntro] : introDialogue;
}
