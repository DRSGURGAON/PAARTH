import '../data/memory_objects.dart';
import 'quest.dart';

/// Memory Master's question types. Phase 5's headline pair is
/// [objectRecall] ("Which one did you see?") and [positionRecall]
/// ("Where was the panda?"); the other three add variety and are
/// generated less often.
enum MemoryQuestionType {
  objectRecall,
  positionRecall,
  missingObject,
  sequenceNext,
  count,
}

/// One jungle friend standing at one scene spot during the study phase.
class MemoryPlacement {
  const MemoryPlacement({required this.object, required this.spot});

  final MemoryObject object;
  final JungleSpot spot;
}

/// One Memory Master round: jungle friends appear at scene spots for
/// [studyDuration], then hide, then [question] asks about what was
/// seen. [question] reuses [ChoiceChallenge] so the answering UI is
/// identical to every other tap-an-answer challenge in the game.
class MemoryRound {
  const MemoryRound({
    required this.placements,
    required this.studyDuration,
    required this.questionType,
    required this.question,
  });

  final List<MemoryPlacement> placements;
  final Duration studyDuration;
  final MemoryQuestionType questionType;
  final ChoiceChallenge question;

  /// The shown objects' emoji, in scene order.
  List<String> get items =>
      [for (final placement in placements) placement.object.emoji];
}
