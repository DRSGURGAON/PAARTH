import '../models/quest.dart';
import '../repositories/progress_repository.dart';
import '../repositories/quest_repository.dart';

/// What happened after the child tapped an answer.
enum AnswerResult {
  /// Wrong option — stay on this challenge, show encouragement.
  incorrect,

  /// Correct — moved on to the next challenge.
  advanced,

  /// Correct on the final challenge — the quest is finished and any
  /// first-time rewards have been applied.
  completed,
}

/// Drives one play-through of a [Quest]: which challenge is current,
/// answer checking, and reward bookkeeping on completion. Plain class
/// with no Flutter imports so the whole quest loop is unit-testable.
class QuestEngine {
  QuestEngine({
    required this.quest,
    required ProgressRepository progressRepository,
    required QuestRepository questRepository,
  })  : _progressRepository = progressRepository,
        _questRepository = questRepository;

  final Quest quest;
  final ProgressRepository _progressRepository;
  final QuestRepository _questRepository;

  /// Gentle, rotating feedback for wrong answers — never "Wrong!" or
  /// "You failed" (design brief section 13).
  static const List<String> encouragements = [
    "Almost! Let's try again! 💪",
    'Good try! Have another go! 🌟',
    "Let's find the answer together! 🔍",
  ];

  int _index = 0;
  int _wrongAttempts = 0;

  /// Stars actually awarded when the quest completed: the quest's
  /// [Quest.starReward] on a first-time clear, 0 on a replay.
  int starsAwarded = 0;

  int get currentIndex => _index;
  bool get isComplete => _index >= quest.challenges.length;
  ChoiceChallenge get currentChallenge => quest.challenges[_index];

  String nextEncouragement() =>
      encouragements[(_wrongAttempts - 1) % encouragements.length];

  Future<AnswerResult> submitAnswer(int optionIndex) async {
    assert(!isComplete, 'submitAnswer called after quest completion');

    if (!currentChallenge.isCorrect(optionIndex)) {
      _wrongAttempts++;
      return AnswerResult.incorrect;
    }

    _index++;
    if (!isComplete) return AnswerResult.advanced;

    if (!_questRepository.isCompleted(quest.id)) {
      await _progressRepository.addStars(quest.starReward);
      await _questRepository.markCompleted(quest.id);
      starsAwarded = quest.starReward;
    }
    return AnswerResult.completed;
  }
}
