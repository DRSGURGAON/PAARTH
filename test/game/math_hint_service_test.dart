import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/math_question.dart';
import 'package:super_kid_adventure/game/systems/math_hint_service.dart';

MathQuestion question({
  required MathQuestionType type,
  required List<int> operands,
  required int answer,
  String? visual,
}) {
  return MathQuestion(
    id: 0,
    type: type,
    operands: operands,
    correctAnswer: answer,
    prompt: 'p',
    options: ['$answer', '${answer + 1}', '${answer + 2}'],
    correctIndex: 0,
    level: 1,
    visual: visual,
  );
}

void main() {
  group('MathHintService', () {
    test('subtraction gets the step-by-step countdown (8 - 3 → 8 → 7 → 6 → 5)',
        () {
      final hint = MathHintService.hintFor(question(
        type: MathQuestionType.subtraction,
        operands: [8, 3],
        answer: 5,
        visual: '🍌🍌🍌🍌🍌🍌🍌🍌',
      ));

      expect(hint.text, contains('8 → 7 → 6 → 5'));
      expect(hint.visual, '🍌🍌🍌🍌🍌🍌🍌🍌');
    });

    test('a long countdown stays verbal instead of a wall of numbers', () {
      final hint = MathHintService.hintFor(question(
        type: MathQuestionType.subtraction,
        operands: [40, 15],
        answer: 25,
      ));

      expect(hint.text, isNot(contains('→')));
      expect(hint.text, contains('40'));
      expect(hint.text, contains('15'));
    });

    test('addition gets a count hint carrying the object visual', () {
      final hint = MathHintService.hintFor(question(
        type: MathQuestionType.addition,
        operands: [3, 2],
        answer: 5,
        visual: '🍎🍎🍎  +  🍎🍎',
      ));

      expect(hint.text.toLowerCase(), contains('count'));
      expect(hint.visual, '🍎🍎🍎  +  🍎🍎');
    });

    test('comparison and sequence hints teach the idea, not the answer', () {
      final comparison = MathHintService.hintFor(question(
        type: MathQuestionType.comparison,
        operands: [7, 5],
        answer: 7,
      ));
      final sequence = MathHintService.hintFor(question(
        type: MathQuestionType.sequence,
        operands: [2, 2],
        answer: 8,
      ));

      expect(comparison.text.toLowerCase(), contains('bigger'));
      expect(comparison.text, isNot(contains('7')));
      expect(sequence.text, contains('2'));
      expect(sequence.text, isNot(contains('8')));
    });
  });
}
