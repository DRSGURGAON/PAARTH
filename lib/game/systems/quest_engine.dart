import '../models/quest.dart';
import '../repositories/coin_repository.dart';
import '../repositories/progress_repository.dart';
import '../repositories/quest_progress_repository.dart';
import '../repositories/quest_repository.dart';
import 'quest_reward_service.dart';

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
/// answer checking, mid-quest save/resume, and reward bookkeeping on
/// completion. Plain class with no Flutter imports so the whole quest
/// loop is unit-testable.
///
/// Construction restores any saved run of the *same* quest (challenge
/// index and miss count), so navigating away mid-quest — or killing the
/// app entirely — resumes at the start of the current challenge instead
/// of resetting (brief section 20).
class QuestEngine {
  QuestEngine({
    required this.quest,
    required ProgressRepository progressRepository,
    required QuestRepository questRepository,
    required CoinRepository coinRepository,
    required QuestProgressRepository questProgressRepository,
  })  : _progressRepository = progressRepository,
        _questRepository = questRepository,
        _coinRepository = coinRepository,
        _questProgressRepository = questProgressRepository {
    final saved = _questProgressRepository.load();
    if (saved != null &&
        saved.questId == quest.id &&
        saved.challengeIndex < quest.challenges.length) {
      _index = saved.challengeIndex;
      _wrongAttempts = saved.wrongAttempts;
    }
  }

  final Quest quest;
  final ProgressRepository _progressRepository;
  final QuestRepository _questRepository;
  final CoinRepository _coinRepository;
  final QuestProgressRepository _questProgressRepository;

  /// Gentle, rotating feedback for wrong answers — never "Wrong!" or
  /// "You failed" (design brief section 13).
  static const List<String> encouragements = [
    "Almost! Let's try again! 💪",
    'Good try! Have another go! 🌟',
    "Let's find the answer together! 🔍",
  ];

  int _index = 0;
  int _wrongAttempts = 0;

  /// Stars actually awarded when the quest completed: the tier from
  /// [QuestRewardService] on a first-time clear, 0 on a replay.
  int starsAwarded = 0;

  /// Coins actually awarded alongside [starsAwarded] — 0 on a replay.
  int coinsAwarded = 0;

  int get currentIndex => _index;
  int get wrongAttempts => _wrongAttempts;
  bool get isComplete => _index >= quest.challenges.length;
  QuestChallenge get currentChallenge => quest.challenges[_index];

  String nextEncouragement() =>
      encouragements[(_wrongAttempts - 1) % encouragements.length];

  Future<AnswerResult> submitAnswer(int optionIndex) async {
    assert(!isComplete, 'submitAnswer called after quest completion');

    if (!currentChallenge.isCorrect(optionIndex)) {
      _wrongAttempts++;
      await _saveProgress();
      return AnswerResult.incorrect;
    }

    _index++;
    if (!isComplete) {
      await _saveProgress();
      return AnswerResult.advanced;
    }

    await _questProgressRepository.clear();
    if (!_questRepository.isCompleted(quest.id)) {
      final reward = QuestRewardService.calculate(
        baseStarReward: quest.starReward,
        wrongAttempts: _wrongAttempts,
      );
      await _progressRepository.addStars(reward.stars);
      await _coinRepository.addCoins(reward.coins);
      await _questRepository.markCompleted(quest.id,
          starsEarned: reward.stars);
      starsAwarded = reward.stars;
      coinsAwarded = reward.coins;
    }
    return AnswerResult.completed;
  }

  Future<void> _saveProgress() {
    return _questProgressRepository.save(QuestProgress(
      questId: quest.id,
      challengeIndex: _index,
      wrongAttempts: _wrongAttempts,
    ));
  }
}
