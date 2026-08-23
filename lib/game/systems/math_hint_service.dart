import '../models/math_question.dart';

/// One gentle hint: a short child-friendly line, plus an optional
/// object line to count along with.
class MathHint {
  const MathHint({required this.text, this.visual});

  final String text;
  final String? visual;
}

/// The reusable hint system (brief section: hints help the child
/// understand, never just hand over the answer). Hint styles per type:
///
/// - addition → **count hint**: count both groups one by one
/// - subtraction → **step hint**: count down step by step (8 → 7 → 6 → 5)
/// - comparison → **count hint**: the number that comes later is bigger
/// - sequence → **step hint**: point out the size of each jump
///
/// Pure function of the question, no Flutter imports — trivially
/// testable, and any screen (Math Dash today, future modes later) can
/// present the same hints.
class MathHintService {
  MathHintService._();

  /// Longest count-down chain worth spelling out; beyond this the hint
  /// stays verbal so it never becomes a wall of numbers.
  static const int maxCountdownSteps = 5;

  static MathHint hintFor(MathQuestion question) {
    switch (question.type) {
      case MathQuestionType.addition:
        return MathHint(
          text: 'Count them all one by one!',
          visual: question.visual,
        );
      case MathQuestionType.subtraction:
        final a = question.operands[0];
        final b = question.operands[1];
        if (b <= maxCountdownSteps) {
          final countdown = List.generate(b + 1, (i) => '${a - i}').join(' → ');
          return MathHint(
            text: 'Count down: $countdown',
            visual: question.visual,
          );
        }
        return MathHint(
          text: 'Start at $a and count down $b — go slowly!',
          visual: question.visual,
        );
      case MathQuestionType.comparison:
        return const MathHint(
          text: 'Count up! The number that comes later is bigger.',
        );
      case MathQuestionType.sequence:
        final step = question.operands[1];
        return MathHint(text: 'Look at the jump — each number grows by $step!');
    }
  }
}
