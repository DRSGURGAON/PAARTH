import '../models/pattern_question.dart';

/// One gentle pattern hint: a short teaching line plus an optional
/// re-drawn pattern row with the repeating groups marked.
class PatternHint {
  const PatternHint({required this.text, this.visual});

  final String text;
  final String? visual;
}

/// Pattern-specific hints (brief section 9): highlight the repeating
/// group and say what repeats — teach *how* to spot the pattern, never
/// hand over the answer. Pure function of the question, no Flutter
/// imports, so any screen can present the same hints.
class PatternHintService {
  PatternHintService._();

  static PatternHint hintFor(PatternQuestion question) {
    if (question.structure == PatternStructure.number) {
      return PatternHint(
        text: 'Each number jumps by ${question.numberStep}!',
      );
    }

    // Re-draw the row with a divider after each full repeat of the
    // unit: 🟢 🔵 | 🟢 🔵 | ❓
    final unitLength = question.unit.length;
    final grouped = StringBuffer();
    for (var i = 0; i < question.sequence.length; i++) {
      if (i > 0 && i % unitLength == 0) grouped.write('| ');
      grouped.write('${question.sequence[i]} ');
    }
    grouped.write('| ❓');

    return PatternHint(
      text: 'Look at what repeats: ${question.unit.join(' ')}',
      visual: grouped.toString(),
    );
  }
}
