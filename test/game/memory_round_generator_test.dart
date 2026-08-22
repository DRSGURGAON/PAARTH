import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/quest.dart';
import 'package:super_kid_adventure/game/systems/memory_round_generator.dart';

void main() {
  group('MemoryRoundGenerator', () {
    late MemoryRoundGenerator generator;

    setUp(() {
      generator = MemoryRoundGenerator(random: Random(7));
    });

    void expectWellFormed(dynamic round) {
      expect(round.items, isNotEmpty);
      expect(round.items.toSet().length, round.items.length,
          reason: 'items must be distinct: ${round.items}');
      expect(round.question.category, ChallengeCategory.memory);
      expect(round.question.options.length, greaterThanOrEqualTo(2));
      expect(
        round.question.options.toSet().length,
        round.question.options.length,
        reason: 'options must be distinct: ${round.question.options}',
      );
      expect(
        round.question.correctIndex,
        inInclusiveRange(0, round.question.options.length - 1),
      );
    }

    test('every level and question type produces well-formed rounds', () {
      for (var level = 1; level <= 5; level++) {
        for (var i = 0; i < 30; i++) {
          expectWellFormed(generator.next(level));
          expectWellFormed(generator.position(level));
          expectWellFormed(generator.sequenceNext(level));
          expectWellFormed(generator.missingObject(level));
          expectWellFormed(generator.count(level));
        }
      }
    });

    test('item count grows with level', () {
      final level1 = generator.position(1).items.length;
      final level5 = generator.position(5).items.length;

      expect(level1, lessThan(level5));
    });

    test('position question answer matches the item at that position', () {
      for (var i = 0; i < 30; i++) {
        final round = generator.position(3);
        final positionMatch =
            RegExp(r'position (\d+)').firstMatch(round.question.prompt)!;
        final index = int.parse(positionMatch.group(1)!) - 1;

        expect(
          round.question.options[round.question.correctIndex],
          round.items[index],
        );
      }
    });

    test('sequenceNext answer is the item right after the anchor', () {
      for (var i = 0; i < 30; i++) {
        final round = generator.sequenceNext(3);
        final anchorMatch =
            RegExp(r'after (.+)\?$').firstMatch(round.question.prompt)!;
        final anchor = anchorMatch.group(1)!;
        final anchorIndex = round.items.indexOf(anchor);
        final expected = round.items[anchorIndex + 1];

        expect(
          round.question.options[round.question.correctIndex],
          expected,
        );
      }
    });

    test('missingObject answer is genuinely not in the studied items', () {
      for (var i = 0; i < 30; i++) {
        final round = generator.missingObject(4);
        final answer = round.question.options[round.question.correctIndex];

        expect(round.items, isNot(contains(answer)));
      }
    });

    test('count question answer equals the number of studied items', () {
      for (var i = 0; i < 30; i++) {
        final round = generator.count(2);
        final answer = round.question.options[round.question.correctIndex];

        expect(int.parse(answer), round.items.length);
      }
    });

    test('study duration is longer for larger item sets', () {
      final small = generator.position(1);
      final large = generator.position(5);

      expect(large.studyDuration, greaterThan(small.studyDuration));
    });
  });
}
