import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/memory_round.dart';
import 'package:super_kid_adventure/game/models/quest.dart';
import 'package:super_kid_adventure/game/systems/memory_round_generator.dart';

void main() {
  group('MemoryRoundGenerator', () {
    late MemoryRoundGenerator generator;

    setUp(() {
      generator = MemoryRoundGenerator(random: Random(7));
    });

    void expectWellFormed(MemoryRound round) {
      expect(round.placements, isNotEmpty);
      expect(
        round.placements.map((p) => p.object.id).toSet().length,
        round.placements.length,
        reason: 'animals must be distinct',
      );
      expect(
        round.placements.map((p) => p.spot.id).toSet().length,
        round.placements.length,
        reason: 'spots must be distinct',
      );
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
          expectWellFormed(generator.objectRecall(level));
          expectWellFormed(generator.positionRecall(level));
          expectWellFormed(generator.sequenceNext(level));
          expectWellFormed(generator.missingObject(level));
          expectWellFormed(generator.count(level));
        }
      }
    });

    test('item count follows the spec: 3 at level 1, 4 at level 2, 5 from '
        'level 3', () {
      expect(generator.objectRecall(1).placements.length, 3);
      expect(generator.objectRecall(2).placements.length, 4);
      expect(generator.objectRecall(3).placements.length, 5);
      expect(generator.objectRecall(5).placements.length, 5);
    });

    test('objectRecall answer really was shown; decoys really were not', () {
      for (var i = 0; i < 30; i++) {
        final round = generator.objectRecall(3);
        final shown = round.items;
        final answer = round.question.options[round.question.correctIndex];

        expect(shown, contains(answer));
        for (var o = 0; o < round.question.options.length; o++) {
          if (o == round.question.correctIndex) continue;
          expect(shown, isNot(contains(round.question.options[o])),
              reason: 'decoys must not have been shown');
        }
      }
    });

    test('positionRecall answer names the spot the animal actually stood at',
        () {
      for (var i = 0; i < 30; i++) {
        final round = generator.positionRecall(3);
        final target = round.placements.firstWhere(
            (p) => round.question.prompt.contains(p.object.label));
        final answer = round.question.options[round.question.correctIndex];

        expect(answer, contains(target.spot.emoji));
        expect(answer.toLowerCase(), contains(target.spot.label));
      }
    });

    test('missingObject answer is genuinely not in the studied items', () {
      for (var i = 0; i < 30; i++) {
        final round = generator.missingObject(4);
        final answer = round.question.options[round.question.correctIndex];

        expect(round.items, isNot(contains(answer)));
      }
    });

    test('sequenceNext answer is the friend right after the anchor', () {
      for (var i = 0; i < 30; i++) {
        final round = generator.sequenceNext(3);
        final anchorEmoji = RegExp(r'after (.+)\?$')
            .firstMatch(round.question.prompt)!
            .group(1)!;
        final anchorIndex = round.items.indexOf(anchorEmoji);
        final expected = round.items[anchorIndex + 1];

        expect(
          round.question.options[round.question.correctIndex],
          expected,
        );
      }
    });

    test('count question answer equals the number of studied items', () {
      for (var i = 0; i < 30; i++) {
        final round = generator.count(2);
        final answer = round.question.options[round.question.correctIndex];

        expect(int.parse(answer), round.placements.length);
      }
    });

    test('study duration is longer for larger scenes and slightly shorter '
        'at top levels', () {
      final small = generator.objectRecall(1);
      final large = generator.objectRecall(3);
      final top = generator.objectRecall(5);

      expect(large.studyDuration, greaterThan(small.studyDuration));
      // Same item count at levels 3 and 5 — the top level trims time.
      expect(top.studyDuration, lessThan(large.studyDuration));
    });
  });
}
