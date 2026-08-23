import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/models/pattern_question.dart';
import 'package:super_kid_adventure/game/systems/pattern_hint_service.dart';

void main() {
  group('PatternHintService', () {
    test('a visual pattern hint marks the repeating groups with dividers',
        () {
      const question = PatternQuestion(
        id: 0,
        type: PatternType.color,
        structure: PatternStructure.ab,
        sequence: ['🟢', '🔵', '🟢', '🔵'],
        unit: ['🟢', '🔵'],
        correctAnswer: '🟢',
        options: ['🟢', '🔵', '🔴'],
        correctIndex: 0,
        level: 1,
      );

      final hint = PatternHintService.hintFor(question);

      expect(hint.text, contains('🟢 🔵'));
      expect(hint.visual, '🟢 🔵 | 🟢 🔵 | ❓');
    });

    test('an AABB hint groups by the full 4-item unit', () {
      const question = PatternQuestion(
        id: 1,
        type: PatternType.object,
        structure: PatternStructure.aabb,
        sequence: ['🍌', '🍌', '🍎', '🍎', '🍌', '🍌'],
        unit: ['🍌', '🍌', '🍎', '🍎'],
        correctAnswer: '🍎',
        options: ['🍎', '🍌', '🍃'],
        correctIndex: 0,
        level: 3,
      );

      final hint = PatternHintService.hintFor(question);

      expect(hint.visual, '🍌 🍌 🍎 🍎 | 🍌 🍌 | ❓');
    });

    test('a number hint names the jump, never the answer', () {
      const question = PatternQuestion(
        id: 2,
        type: PatternType.number,
        structure: PatternStructure.number,
        sequence: ['2', '4', '6'],
        unit: [],
        correctAnswer: '8',
        options: ['8', '7', '10'],
        correctIndex: 0,
        level: 4,
        numberStep: 2,
      );

      final hint = PatternHintService.hintFor(question);

      expect(hint.text, contains('2'));
      expect(hint.text, isNot(contains('8')));
      expect(hint.visual, isNull);
    });
  });
}
