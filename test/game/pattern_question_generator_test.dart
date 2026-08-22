import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/quest.dart';
import 'package:super_kid_adventure/game/systems/pattern_question_generator.dart';

void main() {
  group('PatternQuestionGenerator', () {
    late PatternQuestionGenerator generator;

    setUp(() {
      generator = PatternQuestionGenerator(random: Random(11));
    });

    test('every level produces well-formed questions', () {
      for (var level = 1; level <= 5; level++) {
        for (var i = 0; i < 50; i++) {
          final challenge = generator.next(level);

          expect(challenge.category, ChallengeCategory.logic);
          expect(challenge.visual, isNotNull);
          expect(challenge.options.length, 3);
          expect(challenge.options.toSet().length, 3,
              reason: 'options must be distinct: ${challenge.options}');
          expect(
            challenge.correctIndex,
            inInclusiveRange(0, challenge.options.length - 1),
          );
        }
      }
    });

    test('the correct answer continues the repeating unit shown', () {
      // Unit length is 2 or 3 (see _unitLength table); rather than
      // reverse-engineer which, just confirm the answer matches the
      // element either 2 or 3 positions back — that's what "continues
      // a repeating unit of length 2 or 3" means structurally.
      for (var level = 1; level <= 5; level++) {
        for (var i = 0; i < 50; i++) {
          final challenge = generator.next(level);
          final shown = challenge.visual!
              .replaceAll('❓', '')
              .trim()
              .split(' ')
              .where((s) => s.isNotEmpty)
              .toList();
          final answer = challenge.options[challenge.correctIndex];

          final matchesUnitOf2 =
              shown.length >= 2 && shown[shown.length - 2] == answer;
          final matchesUnitOf3 =
              shown.length >= 3 && shown[shown.length - 3] == answer;
          expect(matchesUnitOf2 || matchesUnitOf3, isTrue,
              reason: 'answer $answer does not continue pattern $shown');
        }
      }
    });
  });
}
