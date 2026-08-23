import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/data/pattern_items.dart';
import 'package:super_kid_adventure/game/models/pattern_question.dart';
import 'package:super_kid_adventure/game/systems/pattern_question_generator.dart';

void main() {
  group('PatternQuestionGenerator', () {
    late PatternQuestionGenerator generator;

    setUp(() {
      generator = PatternQuestionGenerator(random: Random(11));
    });

    void expectWellFormed(PatternQuestion question) {
      expect(question.sequence, isNotEmpty);
      expect(question.options.length, 3);
      expect(question.options.toSet().length, 3,
          reason: 'options must be distinct: ${question.options}');
      expect(
        question.correctIndex,
        inInclusiveRange(0, question.options.length - 1),
      );
      expect(question.options[question.correctIndex], question.correctAnswer);
      expect(question.visual, endsWith('❓'));
    }

    test('every level produces well-formed questions', () {
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

    test('every visual category produces valid patterns of every structure',
        () {
      const visualTypes = [
        PatternType.color,
        PatternType.shape,
        PatternType.animal,
        PatternType.object,
      ];
      for (final type in visualTypes) {
        for (var i = 0; i < 20; i++) {
          for (final question in [
            generator.ab(1, type),
            generator.abc(2, type),
            generator.aabb(3, type),
          ]) {
            expectWellFormed(question);
            expect(question.type, type);
            // Every item shown belongs to the claimed category.
            final emojis =
                PatternItems.forType(type).map((item) => item.emoji).toSet();
            for (final shown in question.sequence) {
              expect(emojis, contains(shown));
            }
          }
        }
      }
    });

    test('AB structure shows A B A B and continues with A', () {
      for (var i = 0; i < 30; i++) {
        final question = generator.ab(1, PatternType.animal);

        expect(question.sequence.length, 4);
        expect(question.sequence[0], question.sequence[2]);
        expect(question.sequence[1], question.sequence[3]);
        expect(question.sequence[0], isNot(question.sequence[1]));
        expect(question.correctAnswer, question.sequence[0]);
      }
    });

    test('ABC structure shows A B C A B and continues with C', () {
      for (var i = 0; i < 30; i++) {
        final question = generator.abc(2, PatternType.shape);

        expect(question.sequence.length, 5);
        expect(question.sequence[3], question.sequence[0]);
        expect(question.sequence[4], question.sequence[1]);
        expect(question.correctAnswer, question.sequence[2]);
      }
    });

    test('AABB structure shows A A B B A A and continues with A... the '
        'element the unit dictates', () {
      for (var i = 0; i < 30; i++) {
        final question = generator.aabb(3, PatternType.object);

        expect(question.sequence.length, 6);
        expect(question.sequence[0], question.sequence[1]);
        expect(question.sequence[2], question.sequence[3]);
        expect(question.sequence[0], isNot(question.sequence[2]));
        // Position 6 in AABB-repeat is the unit's index-2 element (B).
        expect(question.correctAnswer, question.unit[6 % question.unit.length]);
      }
    });

    test('number sequences continue the arithmetic jump with gentle steps',
        () {
      for (var i = 0; i < 30; i++) {
        final question = generator.numberSequence(4);
        final shown = question.sequence.map(int.parse).toList();
        final step = question.numberStep!;

        expect(shown[1] - shown[0], step);
        expect(shown[2] - shown[1], step);
        expect(int.parse(question.correctAnswer), shown[2] + step);
        expect(step, lessThanOrEqualTo(10));
      }
    });

    test('structure complexity is bounded by level: level 1 is always AB, '
        'numbers appear only from level 4', () {
      for (var i = 0; i < 50; i++) {
        expect(generator.next(1).structure, PatternStructure.ab);
        expect(generator.next(2).structure,
            isIn([PatternStructure.ab, PatternStructure.abc]));
        expect(generator.next(3).structure, isNot(PatternStructure.number));
      }
      // Levels 4–5 do reach number sequences.
      var sawNumber = false;
      for (var i = 0; i < 100; i++) {
        if (generator.next(5).structure == PatternStructure.number) {
          sawNumber = true;
        }
      }
      expect(sawNumber, isTrue);
    });
  });
}
