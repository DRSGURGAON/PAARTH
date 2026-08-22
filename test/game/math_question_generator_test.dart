import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/quest.dart';
import 'package:super_kid_adventure/game/systems/math_question_generator.dart';

void main() {
  group('MathQuestionGenerator', () {
    late MathQuestionGenerator generator;

    setUp(() {
      generator = MathQuestionGenerator(random: Random(42));
    });

    void expectWellFormed(ChoiceChallenge challenge) {
      expect(challenge.category, ChallengeCategory.math);
      expect(challenge.prompt, isNotEmpty);
      expect(challenge.options.length, greaterThanOrEqualTo(2));
      expect(challenge.options.toSet().length, challenge.options.length,
          reason: 'options must be distinct: ${challenge.options}');
      expect(
        challenge.correctIndex,
        inInclusiveRange(0, challenge.options.length - 1),
      );
    }

    test('every level produces well-formed questions of every type', () {
      for (var level = 1; level <= 5; level++) {
        for (var i = 0; i < 50; i++) {
          expectWellFormed(generator.next(level));
        }
      }
    });

    test('addition answers are actually the sum', () {
      for (var i = 0; i < 50; i++) {
        final challenge = generator.addition(3);
        final match =
            RegExp(r'What is (\d+) \+ (\d+)\?').firstMatch(challenge.prompt);
        if (match == null) continue; // small sums render as emoji visuals
        final expected =
            int.parse(match.group(1)!) + int.parse(match.group(2)!);
        expect(challenge.options[challenge.correctIndex], '$expected');
      }
    });

    test('subtraction never goes negative', () {
      for (var level = 1; level <= 5; level++) {
        for (var i = 0; i < 50; i++) {
          final challenge = generator.subtraction(level);
          final answer =
              int.parse(challenge.options[challenge.correctIndex]);
          expect(answer, greaterThanOrEqualTo(0));
        }
      }
    });

    test('comparison marks the bigger number as correct', () {
      for (var i = 0; i < 50; i++) {
        final challenge = generator.comparison(4);
        final values =
            challenge.options.map(int.parse).toList();
        final bigger = values.reduce(max);
        expect(values[challenge.correctIndex], bigger);
      }
    });

    test('sequence answers continue the arithmetic pattern', () {
      for (var i = 0; i < 50; i++) {
        final challenge = generator.sequence(2);
        final numbers = RegExp(r'(\d+)')
            .allMatches(challenge.prompt)
            .map((m) => int.parse(m.group(1)!))
            .toList();
        // Prompt contains the three shown terms.
        final step = numbers[1] - numbers[0];
        expect(numbers[2] - numbers[1], step);
        expect(
          challenge.options[challenge.correctIndex],
          '${numbers[2] + step}',
        );
      }
    });

    test('level 1 keeps numbers small enough for age ~7 starters', () {
      for (var i = 0; i < 50; i++) {
        final challenge = generator.addition(1);
        final answer =
            int.parse(challenge.options[challenge.correctIndex]);
        expect(answer, lessThanOrEqualTo(10));
      }
    });
  });
}
