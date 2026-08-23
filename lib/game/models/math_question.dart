/// The four V1 Math Dash topics (brief section 9).
enum MathQuestionType { addition, subtraction, comparison, sequence }

/// One generated Math Dash question — pure data from
/// `MathQuestionGenerator`, consumed by the Math Dash screen and the
/// hint service. Carries its own arithmetic facts ([operands],
/// [correctAnswer]) so hints and tests can reason about the math
/// directly instead of re-parsing prompt strings.
class MathQuestion {
  const MathQuestion({
    required this.id,
    required this.type,
    required this.operands,
    required this.correctAnswer,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.level,
    this.visual,
    this.objectEmoji,
  });

  final int id;
  final MathQuestionType type;

  /// The numbers behind the question: `[a, b]` for addition/subtraction/
  /// comparison, `[start, step]` for a sequence.
  final List<int> operands;

  /// The numeric answer (for comparison: the bigger operand).
  final int correctAnswer;

  /// Short, story-framed question text.
  final String prompt;

  /// Optional countable-objects line shown large above the prompt.
  final String? visual;

  /// The single object emoji [visual] is built from, when it has one —
  /// lets the hint system re-use the same object.
  final String? objectEmoji;

  final List<String> options;
  final int correctIndex;

  /// Difficulty level (1–5) this question was generated at.
  final int level;

  bool isCorrect(int optionIndex) => optionIndex == correctIndex;
}
