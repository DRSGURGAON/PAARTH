/// The pattern categories Pattern Power draws from (brief section 3,
/// A–E). Visual categories use themed items; [number] is a numeric
/// sequence.
enum PatternType { color, shape, animal, object, number }

/// How the repeating unit is structured (brief section 7's difficulty
/// ladder). [number] sequences have no repeating unit.
enum PatternStructure { ab, abc, aabb, number }

/// One generated Pattern Power question — pure data from
/// `PatternQuestionGenerator`, consumed by the screen and the hint
/// service. Carries its own structure facts ([unit], [numberStep]) so
/// hints can teach the pattern without re-parsing display strings.
class PatternQuestion {
  const PatternQuestion({
    required this.id,
    required this.type,
    required this.structure,
    required this.sequence,
    required this.unit,
    required this.correctAnswer,
    required this.options,
    required this.correctIndex,
    required this.level,
    this.numberStep,
    this.prompt = 'What comes next?',
  });

  final int id;
  final PatternType type;
  final PatternStructure structure;

  /// The items shown before the missing slot, in order.
  final List<String> sequence;

  /// The repeating unit ('🟢 🔵' → ['🟢','🔵']); empty for number
  /// sequences.
  final List<String> unit;

  final String correctAnswer;
  final List<String> options;
  final int correctIndex;
  final int level;

  /// The jump between terms, for number sequences only.
  final int? numberStep;

  final String prompt;

  /// The display row: shown items plus the missing slot.
  String get visual => '${sequence.join(' ')} ❓';

  bool isCorrect(int optionIndex) => optionIndex == correctIndex;
}
