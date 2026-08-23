import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/math_question.dart';
import 'package:super_kid_adventure/game/systems/math_question_generator.dart';

void main() {
  group('MathQuestionGenerator', () {
    late MathQuestionGenerator generator;

    setUp(() {
      generator = MathQuestionGenerator(random: Random(42));
    });

    void expectWellFormed(MathQuestion question) {
      expect(question.prompt, isNotEmpty);
      expect(question.options.length, greaterThanOrEqualTo(2));
      expect(question.options.toSet().length, question.options.length,
          reason: 'options must be distinct: ${question.options}');
      expect(
        question.correctIndex,
        inInclusiveRange(0, question.options.length - 1),
      );
      // The marked option always displays the recorded numeric answer.
      expect(question.options[question.correctIndex],
          '${question.correctAnswer}');
      expect(question.operands.length, 2);
    }

    test('every level produces well-formed questions of every type', () {
      for (var level = 1; level <= 5; level++) {
        for (var i = 0; i < 50; i++) {
          expectWellFormed(generator.next(level));
        }
      }
    });

    test('question ids are unique across a session', () {
      final ids = List.generate(20, (_) => generator.next(2).id);

      expect(ids.toSet().length, ids.length);
    });

    test('addition answers are actually the sum of the operands', () {
      for (var i = 0; i < 50; i++) {
        final question = generator.addition(3);
        expect(question.type, MathQuestionType.addition);
        expect(question.correctAnswer,
            question.operands[0] + question.operands[1]);
      }
    });

    test('subtraction answers are the difference and never negative', () {
      for (var level = 1; level <= 5; level++) {
        for (var i = 0; i < 50; i++) {
          final question = generator.subtraction(level);
          expect(question.correctAnswer,
              question.operands[0] - question.operands[1]);
          expect(question.correctAnswer, greaterThanOrEqualTo(0));
        }
      }
    });

    test('comparison marks the bigger number as correct', () {
      for (var i = 0; i < 50; i++) {
        final question = generator.comparison(4);
        expect(question.correctAnswer,
            max(question.operands[0], question.operands[1]));
        expect(question.options[question.correctIndex],
            '${question.correctAnswer}');
      }
    });

    test('sequence answers continue the arithmetic pattern', () {
      for (var i = 0; i < 50; i++) {
        final question = generator.sequence(2);
        final start = question.operands[0];
        final step = question.operands[1];
        expect(question.correctAnswer, start + step * 3);
        expect(question.prompt,
            contains('$start, ${start + step}, ${start + step * 2}'));
      }
    });

    test('small quantities come with a countable-object visual', () {
      var sawVisual = false;
      for (var i = 0; i < 50; i++) {
        final question = generator.addition(1);
        if (question.visual != null) {
          sawVisual = true;
          expect(question.objectEmoji, isNotNull);
          expect(question.visual, contains(question.objectEmoji!));
        }
      }
      expect(sawVisual, isTrue,
          reason: 'level 1 sums are small; visuals should appear');
    });

    test('level 1 keeps numbers small enough for age ~7 starters', () {
      for (var i = 0; i < 50; i++) {
        expect(generator.addition(1).correctAnswer, lessThanOrEqualTo(10));
        // Operands cap at 5, +1 possible when both rolled equal.
        expect(generator.subtraction(1).operands[0], lessThanOrEqualTo(6));
      }
    });

    test('higher levels actually reach bigger numbers', () {
      var sawBig = false;
      for (var i = 0; i < 100; i++) {
        if (generator.addition(5).correctAnswer > 50) sawBig = true;
      }
      expect(sawBig, isTrue);
    });
  });
}
