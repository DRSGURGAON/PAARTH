import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/systems/quick_challenge_generator.dart';

void main() {
  group('QuickChallengeGenerator', () {
    test('ships the ten templates the design brief asks for', () {
      expect(QuickChallengeGenerator.templateCount, 10);
    });

    test('every template produces a well-formed round', () {
      final generator = QuickChallengeGenerator(random: Random(7));
      for (var i = 0; i < QuickChallengeGenerator.templateCount; i++) {
        final round = generator.roundForTemplate(i);
        expect(round.templateId, isNotEmpty);
        expect(round.instruction, isNotEmpty);
        expect(round.tiles, isNotEmpty, reason: 'template $i has no tiles');
        expect(round.targetIndices, isNotEmpty,
            reason: 'template $i has nothing to tap');
        for (final index in round.targetIndices) {
          expect(index, inInclusiveRange(0, round.tiles.length - 1),
              reason: 'template $i targets a missing tile');
        }
      }
    });

    test('a full bag of draws covers all ten templates without repeats', () {
      final generator = QuickChallengeGenerator(random: Random(3));
      final seen = <String>{};
      for (var i = 0; i < QuickChallengeGenerator.templateCount; i++) {
        seen.add(generator.next().templateId);
      }
      expect(seen.length, QuickChallengeGenerator.templateCount);
    });

    test('count templates: the correct tile matches the number of things '
        'shown', () {
      final generator = QuickChallengeGenerator(random: Random(11));
      for (final template in const [1, 6]) {
        final round = generator.roundForTemplate(template);
        expect(round.targetIndices.length, 1);
        final answer = int.parse(round.tiles[round.targetIndices.single]);
        // The visual is the counted emoji repeated; each is one rune.
        expect(answer, round.visual!.runes.length);
      }
    });

    test('bigger/smaller templates really point at the bigger/smaller '
        'number', () {
      final generator = QuickChallengeGenerator(random: Random(5));
      for (var run = 0; run < 20; run++) {
        final bigger = generator.roundForTemplate(3);
        final values = bigger.tiles.map(int.parse).toList();
        expect(
          int.parse(bigger.tiles[bigger.targetIndices.single]),
          values.reduce(max),
        );

        final smaller = generator.roundForTemplate(8);
        final smallValues = smaller.tiles.map(int.parse).toList();
        expect(
          int.parse(smaller.tiles[smaller.targetIndices.single]),
          smallValues.reduce(min),
        );
      }
    });

    test('odd-one-out has exactly one different tile, and it is the '
        'target', () {
      final generator = QuickChallengeGenerator(random: Random(2));
      final round = generator.roundForTemplate(2);
      final counts = <String, int>{};
      for (final tile in round.tiles) {
        counts[tile] = (counts[tile] ?? 0) + 1;
      }
      final oddTile =
          counts.entries.singleWhere((entry) => entry.value == 1).key;
      expect(round.tiles[round.targetIndices.single], oddTile);
    });

    test('match-shape target tile equals the shown shape', () {
      final generator = QuickChallengeGenerator(random: Random(13));
      for (var run = 0; run < 10; run++) {
        final round = generator.roundForTemplate(5);
        expect(round.tiles[round.targetIndices.single], round.visual);
        expect(round.tiles.toSet().length, round.tiles.length,
            reason: 'decoy shapes must be distinct from the match');
      }
    });

    test('first-letter target really starts the pictured word', () {
      final generator = QuickChallengeGenerator(random: Random(17));
      for (var run = 0; run < 10; run++) {
        final round = generator.roundForTemplate(9);
        final word = round.visual!.split(' ').last;
        expect(round.tiles[round.targetIndices.single], word[0]);
      }
    });

    test('tap-all rounds only mark real target tiles', () {
      final generator = QuickChallengeGenerator(random: Random(23));
      for (final template in const [0, 4, 7]) {
        final round = generator.roundForTemplate(template);
        expect(round.targetIndices.length, greaterThanOrEqualTo(3));
        final targetEmoji =
            round.targetIndices.map((i) => round.tiles[i]).toSet();
        expect(targetEmoji.length, 1,
            reason: 'all targets in a tap-all round show the same thing');
        for (var i = 0; i < round.tiles.length; i++) {
          if (round.targetIndices.contains(i)) continue;
          expect(round.tiles[i], isNot(targetEmoji.single),
              reason: 'a decoy tile shows the target emoji');
        }
      }
    });

    test('an out-of-range template index throws instead of silently '
        'looping', () {
      final generator = QuickChallengeGenerator(random: Random(1));
      expect(
        () => generator
            .roundForTemplate(QuickChallengeGenerator.templateCount),
        throwsArgumentError,
      );
    });
  });
}
