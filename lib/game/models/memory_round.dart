import 'quest.dart';

/// Memory Master's four question types (design brief section 9B):
/// remember position, what came next in sequence, whether an object was
/// seen, or how many objects there were.
enum MemoryQuestionType { position, sequenceNext, missingObject, count }

/// One Memory Master round: a set of items shown for [studyDuration],
/// then hidden, then [question] asked about what was seen. [question]
/// reuses [ChoiceChallenge] so the answering UI is identical to every
/// other tap-an-answer challenge in the game.
class MemoryRound {
  const MemoryRound({
    required this.items,
    required this.studyDuration,
    required this.questionType,
    required this.question,
  });

  final List<String> items;
  final Duration studyDuration;
  final MemoryQuestionType questionType;
  final ChoiceChallenge question;
}
